module GovukHealthcheck
  class SidekiqQueueLatencyCheck < SidekiqQueueCheck
    def name
      :sidekiq_queue_latency
    end

    def queues
      @queues ||= Sidekiq::Stats.new.queues.keys.each_with_object({}) do |name, hash|
        hash[name] = Sidekiq::Queue.new(name).latency
      end
    end
  end
end
