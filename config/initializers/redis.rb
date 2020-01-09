$redis = Redis.new
API_STATUS = Redis::Namespace.new(:api_status, redis: redis)
FACEBOOK_CACHE = Redis::Namespace.new(:facebook, redis: redis)
