module GovukHealthcheck
  class ThresholdCheck
    def status
      if value >= critical_threshold
        :critical
      elsif value >= warning_threshold
        :warning
      else
        :ok
      end
    end

    def message
      if value >= critical_threshold
        "#{value} is above the critical threshold (#{critical_threshold})"
      elsif value >= warning_threshold
        "#{value} is above the warning threshold (#{warning_threshold})"
      else
        "#{value} is below the critical and warning thresholds"
      end
    end

    def details
      {
        value: value,
        total: total,
        thresholds: {
          critical: critical_threshold,
          warning: warning_threshold,
        },
      }
    end

    def value
      raise "This method must be overridden to be the check value."
    end

    def total
      nil # This method can be overriden to provide the total for the check.
    end

    def critical_threshold
      raise "This method must be overriden to be the critical threshold."
    end

    def warning_threshold
      raise "This method must be overriden to be the warning threshold."
    end
  end
end
