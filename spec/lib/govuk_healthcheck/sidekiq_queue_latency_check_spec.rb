require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqQueueLatencyCheck do
  subject { TestQueueLatencyCheck.new }

  let(:sidekiq_stats) { double(queues: { test: 10 }) }
  let(:sidekiq_queue) { double(latency: 5) }

  let(:sidekiq_stats_class) { double }
  let(:sidekiq_queue_class) { double }

  before do
    allow(sidekiq_stats_class).to receive(:new).and_return(sidekiq_stats)
    allow(sidekiq_queue_class).to receive(:new).with(:test).and_return(sidekiq_queue)

    stub_const("Sidekiq::Stats", sidekiq_stats_class)
    stub_const("Sidekiq::Queue", sidekiq_queue_class)
  end

  it_behaves_like "a healthcheck"

  class TestQueueLatencyCheck < GovukHealthcheck::SidekiqQueueLatencyCheck
    def warning_threshold(queue:) # rubocop:disable Lint/UnusedMethodArgument
      10
    end

    def critical_threshold(queue:) # rubocop:disable Lint/UnusedMethodArgument
      20
    end
  end
end
