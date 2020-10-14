module GovukHealthcheck
  class Mongoid
    def name
      :database_connectivity
    end

    def status
      ::Mongoid.default_client.database_names.any?
      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
