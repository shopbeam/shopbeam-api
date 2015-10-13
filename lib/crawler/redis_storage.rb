module Crawler
  class RedisStorage
    EXPIRE_TIME = 86400 # 24 hours * 60 minutes * 60 seconds

    def initialize(name)
      @name = name
    end

    def push(key, value)
      Sidekiq.redis do |conn|
        conn.hmset storage_key, key, value.is_a?(String) ? value : value.to_json
        conn.expire storage_key, EXPIRE_TIME
      end
    end

    def all
      result = Sidekiq.redis do |conn|
        conn.hgetall(storage_key)
      end || {}
      result.each do |k,v|
        begin
          result[k] = JSON.parse(v)
        rescue JSON::ParserError
        end
      end
    end

    def legacy_results=(results)
      Sidekiq.redis do |conn|
        conn.set legacy_storage_key, results
        conn.expire legacy_storage_key, EXPIRE_TIME
      end
    end

    def legacy_results
      Sidekiq.redis do |conn|
        conn.get legacy_storage_key
      end
    end

    private
    def storage_key
      "results-#{@name}"
    end

    def legacy_storage_key
      "legacy-results-#{@name}"
    end
  end
end
