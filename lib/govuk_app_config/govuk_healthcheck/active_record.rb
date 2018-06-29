module GovukHealthcheck
  class ActiveRecord
    def name
      :database_connectivity
    end

    def status
      ::ActiveRecord::Base.connected? ? OK : CRITICAL
    end
  end
end
