module GovukHealthcheck
  STATUSES = [
    OK = :ok,
    WARNING = :warning,
    CRITICAL = :critical,
  ].freeze

  class Checkup
    # @param checks [Array] Array of objects/classes that respond to `run`
    def initialize(checks)
      @checks = checks
    end

    def run
      {
        status: worst_status,
        checks: component_statuses,
      }
    end

  private

    attr_reader :checks

    def component_statuses
      @component_statuses ||= checks.map(&:new).each_with_object({}) do |check, hash|
        hash[check.name] = build_component_status(check)
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

    def build_component_status(check)
      component_status = details(check).merge(status: check.status)
      component_status[:message] = check.message if check.respond_to?(:message)
      component_status
    end

    def details(check)
      check.respond_to?(:details) ? check.details : {}
    end
  end
end
