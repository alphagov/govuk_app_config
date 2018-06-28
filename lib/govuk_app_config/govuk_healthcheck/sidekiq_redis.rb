module GovukHealthcheck
  class SidekiqRedis
    def name
      :redis_connectivity
    end

    def status
      Sidekiq.redis_info ? OK : CRITICAL
    end
  end
end
