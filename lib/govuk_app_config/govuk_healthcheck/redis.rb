module GovukHealthcheck
  class Redis
    def name
      :redis
    end

    def status
      client = ::Redis.new

      client.set("healthcheck", "val")
      client.get("healthcheck")
      client.del("healthcheck")

      client.close

      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
