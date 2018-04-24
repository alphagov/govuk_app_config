module GovukHealthcheck
  module ActiveRecord
    def self.call
      {
        database_connectivity: {
          status: ::ActiveRecord::Base.connected? ? OK : CRITICAL
        }
      }
    end
  end
end
