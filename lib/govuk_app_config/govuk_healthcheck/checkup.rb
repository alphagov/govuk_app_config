module GovukHealthcheck
  OK = "ok".freeze
  WARNING = "warning".freeze
  CRITICAL = "critical".freeze

  class Checkup
    # @param checks [Array] Array of objects/classes that respond to `run`
    def initialize(checks)
      @checks = checks
    end

    def as_json
      {
        status: worst_status,
        checks: component_statuses,
      }
    end

  private

    def component_statuses
      @component_statuses ||= @checks.reduce({}) do |hash, check|
        hash.merge(check.call)
      end
    end

    def worst_status
      if status?(CRITICAL)
        CRITICAL
      elsif status?(WARNING)
        WARNING
      else
        OK
      end
    end

    def status?(status)
      component_statuses.values.any? {|s| s[:status] == status }
    end
  end
end
