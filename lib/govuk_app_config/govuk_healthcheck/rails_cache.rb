module GovukHealthcheck
  class RailsCache
    def name
      :rails_cache
    end

    def status
      ::Rails.cache.write("healthcheck-cache", true)
      raise unless ::Rails.cache.read("healthcheck-cache")

      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
