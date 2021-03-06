class RssFeed
  def initialize(feed_url)
    @feed_url = feed_url;
  end

  def as_json
    feed_url = URI.encode(@feed_url)
    feed_body = HTTParty.get(feed_url).parsed_response
    results = feed_body.is_a?(Hash) ? feed_body : Hash.from_xml(feed_body)

    { results: results }.to_json
  end
end
