module GovukHealthcheck
  class ActiveRecord
    def name
      :database_connectivity
    end

    def status
      ::ActiveRecord::Base.connection
      OK
    rescue StandardError
      CRITICAL
    end
  end
end
