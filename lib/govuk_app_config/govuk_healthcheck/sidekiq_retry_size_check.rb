module GovukHealthcheck
  class SidekiqRetrySizeCheck < ThresholdCheck
    def name
      :sidekiq_retry_size
    end

    def value
      Sidekiq::Stats.new.retry_size
    end
  end
end
