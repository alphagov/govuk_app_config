module GovukHealthcheck
  module SidekiqRedis
    def self.name
      :redis_connectivity
    end

    def self.status
      Sidekiq.redis_info ? OK : CRITICAL
    end

    def self.details
      {}
    end
  end
end
