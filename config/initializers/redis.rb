options = {}
options[:url] = URI.parse(ENV["REDISTOGO_URL"]) if ENV["REDISTOGO_URL"]
redis_connection = Redis.new(options)

API_STATUS = Redis::Namespace.new(:api_status, redis: redis_connection)
FACEBOOK_CACHE = Redis::Namespace.new(:facebook, redis: redis_connection) 
