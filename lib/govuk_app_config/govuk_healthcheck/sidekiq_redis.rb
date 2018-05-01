module GovukHealthcheck
  module SidekiqRedis
    def self.name
      :redis_connectivity
    end

    def self.status
      Sidekiq.redis_info ? OK : CRITICAL
    end
  end
end
