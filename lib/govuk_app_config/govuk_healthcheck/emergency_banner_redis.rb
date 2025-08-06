require "securerandom"

module GovukHealthcheck
  class EmergencyBannerRedis
    def name
      :emergency_banner_redis_connectivity
    end

    def status
      client = ::Redis.new(
        url: ENV["EMERGENCY_BANNER_REDIS_URL"],
        reconnect_attempts: [2, 5, 15], # Purposefully short since this is a healthcheck
      )

      key = "healthcheck-emergency-banner-#{SecureRandom.hex}"

      client.set(key, "val")
      client.get(key)
      client.del(key)

      client.close

      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
