module GovukHealthcheck
  class SidekiqRedis
    def name
      :redis_connectivity
    end

    def status
      # Sidekiq 7 introduced a default_configuration object which has .redis_info
      # for querying Redis information. If the default_configuration object isn't present,
      # we can fall back to the old method of querying it using 'Sidekiq.redis_info'.
      if Sidekiq.respond_to?(:default_configuration)
        Sidekiq.default_configuration.redis_info ? OK : CRITICAL
      else
        Sidekiq.redis_info ? OK : CRITICAL
      end
    rescue StandardError
      # One would expect a Redis::BaseConnectionError, but this should be
      # critical if any exception is raised when making a call to redis.
      CRITICAL
    end
  end
end
