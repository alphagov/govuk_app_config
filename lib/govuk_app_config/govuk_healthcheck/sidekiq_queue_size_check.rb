module GovukHealthcheck
  class SidekiqQueueSizeCheck < SidekiqQueueCheck
    def name
      :sidekiq_queue_size
    end

    def queues
      @queues ||= Sidekiq::Stats.new.queues
    end
  end
end
