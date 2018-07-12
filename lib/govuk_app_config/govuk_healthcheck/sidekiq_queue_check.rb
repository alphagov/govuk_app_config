module GovukHealthcheck
  class SidekiqQueueCheck
    def status
      queues.each do |name, value|
        if value >= critical_threshold(queue: name)
          return :critical
        elsif value >= warning_threshold(queue: name)
          return :warning
        end
      end

      :ok
    end

    def message
      messages = queues.map do |name, value|
        critical = critical_threshold(queue: name)
        warning = warning_threshold(queue: name)

        if value >= critical
          "#{name} (#{value}) is above the critical threshold (#{critical})"
        elsif value >= warning
          "#{name} (#{value}) is above the warning threshold (#{warning})"
        end
      end

      messages = messages.compact

      if messages.empty?
        "all queues are below the critical and warning thresholds"
      else
        messages.join("\n")
      end
    end

    def details
      {
        queues: queues.each_with_object({}) do |(name, value), hash|
          hash[name] = {
            value: value,
            thresholds: {
              critical: critical_threshold(queue: name),
              warning: warning_threshold(queue: name),
            },
          }
        end,
      }
    end

    def queues
      raise "This method must be overriden to be a hash of queue names and data."
    end

    def critical_threshold(queue:)
      raise "This method must be overriden to be the critical threshold."
    end

    def warning_threshold(queue:)
      raise "This method must be overriden to be the warning threshold."
    end
  end
end
