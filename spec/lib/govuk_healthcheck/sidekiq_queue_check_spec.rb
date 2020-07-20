require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqQueueCheck do
  context "an ok check" do
    subject { TestQueueCheck.new({ queue: 0 }, 10, 20) }

    it_behaves_like "a healthcheck"

    its(:status) { is_expected.to eq(:ok) }
    its(:message) { is_expected.to match(/below the critical and warning thresholds/) }
    its(:details) do
      is_expected.to match(
        queues: {
          queue: hash_including(value: 0, thresholds: { warning: 10, critical: 20 })
        },
      )
    end
  end

  context "a warning check" do
    subject { TestQueueCheck.new({ queue: 11 }, 10, 20) }

    it_behaves_like "a healthcheck"

    its(:status) { is_expected.to eq(:warning) }
    its(:message) { is_expected.to match(/above the warning threshold/) }
    its(:details) do
      is_expected.to match(
        queues: {
          queue: hash_including(value: 11, thresholds: { warning: 10, critical: 20 })
        },
      )
    end
  end

  context "a critical check" do
    subject { TestQueueCheck.new({ queue: 21 }, 10, 20) }

    it_behaves_like "a healthcheck"

    its(:status) { is_expected.to eq(:critical) }
    its(:message) { is_expected.to match(/above the critical threshold/) }
    its(:details) do
      is_expected.to match(
        queues: {
          queue: hash_including(value: 21, thresholds: { warning: 10, critical: 20 })
        },
      )
    end
  end

  context "NaNs and infinities" do
    subject { TestQueueCheck.new({ queue: 0 }, Float::INFINITY, Float::NAN) }

    it_behaves_like "a healthcheck"

    its(:status) { is_expected.to eq(:ok) }
    its(:message) { is_expected.to match(/below the critical and warning thresholds/) }
    its(:details) do
      is_expected.to match(
        queues: {
          queue: hash_including(value: 0, thresholds: {})
        },
      )
    end
  end

  class TestQueueCheck < GovukHealthcheck::SidekiqQueueCheck
    def initialize(queues, warning_threshold, critical_threshold, name = :test)
      @queues = queues
      @warning_threshold = warning_threshold
      @critical_threshold = critical_threshold
      @name = name
    end

    attr_reader :queues, :name

    def warning_threshold(queue:)
      @warning_threshold
    end

    def critical_threshold(queue:)
      @critical_threshold
    end
  end
end
