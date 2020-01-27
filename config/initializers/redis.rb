options = {}
options[:url] = URI.parse(ENV["CACHE_STORE_URL"]) if ENV["CACHE_STORE_URL"]
redis = Redis.new(options)
API_STATUS = Redis::Namespace.new(:api_status, redis: redis)
FACEBOOK_CACHE = Redis::Namespace.new(:facebook, redis: redis)
