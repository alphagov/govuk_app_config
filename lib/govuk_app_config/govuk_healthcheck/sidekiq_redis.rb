module GovukHealthcheck
  module SidekiqRedis
    def self.call
      {
        redis_connectivity: {
          status: Sidekiq.redis_info ? OK : CRITICAL
        }
      }
    end
  end
end
