module GovukHealthcheck
  module ActiveRecord
    def self.name
      :database_connectivity
    end

    def self.status
      ::ActiveRecord::Base.connected? ? OK : CRITICAL
    end
  end
end
