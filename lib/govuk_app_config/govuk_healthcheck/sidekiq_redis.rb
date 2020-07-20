module GovukHealthcheck
  class SidekiqRedis
    def name
      :redis_connectivity
    end

    def status
      Sidekiq.redis_info ? OK : CRITICAL
    rescue StandardError
      # One would expect a Redis::BaseConnectionError, but this should be
      # critical if any exception is raised when making a call to redis.
      CRITICAL
    end
  end
end
