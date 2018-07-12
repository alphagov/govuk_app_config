require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqQueueSizeCheck do
  subject { TestQueueSizeCheck.new }

  let(:sidekiq_stats) { double(queues: { test: 10 }) }
  let(:sidekiq_stats_class) { double }

  before do
    allow(sidekiq_stats_class).to receive(:new).and_return(sidekiq_stats)
    stub_const("Sidekiq::Stats", sidekiq_stats_class)
  end

  it_behaves_like "a healthcheck"

  class TestQueueSizeCheck < GovukHealthcheck::SidekiqQueueSizeCheck
    def warning_threshold(queue:)
      100
    end

    def critical_threshold(queue:)
      200
    end
  end
end
