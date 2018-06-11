class FacebookFeed
  CACHE_LIMIT = 18.hours
  CACHE_INTERVAL = 12.hours
  API_REST_INTERVAL = 60.minutes
  API_SAFE_THRESHOLD = 75
  API_CRITICAL_THRESHOLD = 95 

  def initialize(page_id)
    @page_id = page_id
    raw_api_status = API_STATUS.get(:facebook) || { time: Time.now, status: 0 }.to_json
    @api_status = JSON.parse(raw_api_status)
    @api_usage = @api_status['status']
    @usage_timestamp = Time.parse(@api_status['time'])
    @cached_feed = FACEBOOK_CACHE.get(@page_id)
    @parsed_cache = JSON.parse(@cached_feed) if @cached_feed
    @data_timestamp = Time.parse(@parsed_cache['time']) if @parsed_cache
    @now = Time.now
    @age_of_feed = ((@now - @data_timestamp)/1.hour).round(2) if @data_timestamp
  end

  def fetch_from_cache_or_api
    if api_is_idle? || feed_is_too_old?
      data = feed_from_api
    elsif api_needs_rest?
      data = feed_from_cache
    elsif !api_is_strong? && !feed_is_old?
      data = feed_from_cache
    elsif api_is_strong? || is_new_feed?
      data = feed_from_api
    elsif feed_is_old? && !api_needs_rest?
      data = feed_from_api
    else
      puts "//////////////////////////////////////////////////////////////////////////////////////"
      puts "//////////////////////////// Shouldn't ever land here ////////////////////////////////"
      puts "//////////////////////////////////////////////////////////////////////////////////////"
      data = api_down_response
    end
    return data
  end

  private

  def feed_from_cache
    if @parsed_cache
      puts "########################### Serving From Cache: #{@page_id} from #{ @age_of_feed } hours ago ###########################"
      data = @parsed_cache['data']
    else
      puts "*************************** Serving API error response ********************"
      data = api_down_response
    end
  end

  def feed_from_api
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Hitting the API for data: #{@page_id} $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    fields = ["id", "from", "message", "picture", "link", "type", "created_time", "updated_time"]
    facebook_feed_uri = URI.encode("https://graph.facebook.com/v2.12/#{@page_id}/posts?access_token=#{ENV['FACEBOOK_APP_ID']}|#{ENV['FACEBOOK_APP_SECRET']}&fields=#{fields.join(',')}")
    response = HTTParty.get(facebook_feed_uri)

    data = response.parsed_response
    api_status = { time: @now, status: JSON.parse(response.headers["x-app-usage"])["call_count"] }
    cached_feed = { time: @now, data: data }

    API_STATUS.set(:facebook, api_status.to_json)
    FACEBOOK_CACHE.set(@page_id, cached_feed.to_json)

    puts "??????????????????????????????????? API Usage: #{api_status} ?????????????????????????????????????????"

    return data
  end

  def api_is_idle?
    @now > @usage_timestamp + API_REST_INTERVAL
  end

  def api_needs_rest?
    @api_usage > API_CRITICAL_THRESHOLD && @now < @usage_timestamp + API_REST_INTERVAL
  end

  def api_is_strong?
    @api_usage < API_SAFE_THRESHOLD
  end

  def is_new_feed?
    !@cached_feed.nil?
  end

  def feed_is_old?
    return true if @parsed_cache.nil?
    (Time.parse(@parsed_cache["time"]) + CACHE_INTERVAL) < @now
  end

  def feed_is_too_old?
    return false if @parsed_cache.nil?
    (Time.parse(@parsed_cache["time"]) + CACHE_LIMIT) < @now
  end

  def api_down_response
    { data: [ { id: "1",
                message: "The Facebook API is currently down. Please try again later",
                from: { id: "", name: "Facebook" }
              }
            ]
    }
  end
end