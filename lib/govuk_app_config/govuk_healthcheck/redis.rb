require "securerandom"

module GovukHealthcheck
  class Redis
    def name
      :redis_connectivity
    end

    def status
      client = ::Redis.new

      key = "healthcheck-#{SecureRandom.hex}"

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
