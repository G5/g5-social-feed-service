class FacebookFeed
  API_VERSION = "https://graph.facebook.com/v2.12"

  CACHE_INTERVAL = 12.hours      # Time after which we actively attempt to refresh cached data
  API_REST_INTERVAL = 60.minutes # Amount of time to rest the API after we've maxed it out
  API_SAFE_THRESHOLD = 75        # Usage rate under which we proactively rewarm cache with each request
  API_CRITICAL_THRESHOLD = 95    # Usage rate that triggers a moratorium on API hits for the API_REST_INTERVAL

  def initialize(page_id)
    @page_id = page_id
    raw_api_status = API_STATUS.get(:facebook) || { time: Time.now, status: 0 }.to_json
    @api_status = JSON.parse(raw_api_status)
    @api_usage = @api_status['status']
    @usage_timestamp = Time.parse(@api_status['time'])
    @cached_feed = FACEBOOK_CACHE.get(@page_id)
    @parsed_cache = JSON.parse(@cached_feed) if @cached_feed
    @now = Time.now

    # REMOVE @age_of_feed AND @data_timestamp AFTER REVIEW/MONITOR PERIOD
    @data_timestamp = Time.parse(@parsed_cache['time']) if @parsed_cache
    @age_of_feed = ((@now - @data_timestamp)/1.hour).round(2) if @data_timestamp
  end

  def fetch_from_cache_or_api
    if api_is_idle? || api_is_strong? || (feed_needs_refresh? && api_ok?)
      feed_from_api
    elsif api_needs_rest? || feed_is_fresh?
      feed_from_cache
    else
      feed_from_cache
    end
  end

  private

  def feed_from_cache
    if @parsed_cache
      # REMOVE LOGGING AFTER REVIEW/MONITOR PERIOD
      Rails.logger.info("########################### Serving From Cache: #{@page_id} from #{ @age_of_feed } hours ago ###########################")
      data = @parsed_cache['data']
    else
      data = api_down_response
    end
  end

  def feed_from_api
    fields = ["id", "from", "message", "picture", "link", "type", "created_time", "updated_time"]
    facebook_feed_uri = URI.encode("#{API_VERSION}/#{@page_id}/posts?access_token=#{ENV['FACEBOOK_APP_ID']}|#{ENV['FACEBOOK_APP_SECRET']}&fields=#{fields.join(',')}")
    response = HTTParty.get(facebook_feed_uri)
    data = response.parsed_response

    api_status = { time: @now, status: JSON.parse(response.headers["x-app-usage"])["call_count"] }
    cached_feed = { time: @now, data: data }

    API_STATUS.set(:facebook, api_status.to_json)
    FACEBOOK_CACHE.set(@page_id, cached_feed.to_json)

    # REMOVE LOGGING AFTER REVIEW/MONITOR PERIOD
    Rails.logger.info("????????????????????????????? API Hit for #{@page_id}: #{api_status} ?????????????????????????????????????????")

    return data
  end

  def api_is_idle?
    @now > @usage_timestamp + API_REST_INTERVAL
  end

  def api_needs_rest?
    @api_usage > API_CRITICAL_THRESHOLD && @now < @usage_timestamp + API_REST_INTERVAL
  end

  def api_ok?
    @api_usage < API_CRITICAL_THRESHOLD
  end

  def api_is_strong?
    @api_usage < API_SAFE_THRESHOLD
  end

  def is_new_feed?
    !@cached_feed.nil?
  end

  def feed_is_fresh?
    return false if @parsed_cache.nil? # New feeds treated same as data older than 12hrs.
    (Time.parse(@parsed_cache["time"]) + CACHE_INTERVAL) > @now
  end

  def feed_needs_refresh?
    return true if @parsed_cache.nil? # New feeds treated same as data older than 12hrs.
    (Time.parse(@parsed_cache["time"]) + CACHE_INTERVAL) < @now
  end

  def api_down_response
    # REMOVE LOGGING AFTER REVIEW/MONITOR PERIOD
    Rails.logger.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!! Unexpected result for #{@page_id} !!!!!!!!!!!!!!!!!!!!!!!!!!!!")

    { data: [ { id: "1",
                message: "The Facebook API is currently down. Please try again later",
                from: { id: "", name: "Facebook" }
              }
            ]
    }
  end
end
