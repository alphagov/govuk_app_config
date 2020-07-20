require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::ThresholdCheck do
  context "an ok check" do
    subject { TestThresholdCheck.new(0, 10, 20) }

    it_behaves_like "a healthcheck"

    its(:status) { is_expected.to eq(:ok) }
    its(:message) { is_expected.to match(/below the critical and warning thresholds/) }
    its(:details) do
      is_expected.to match(
        hash_including(value: 0, thresholds: { warning: 10, critical: 20 }),
      )
    end
  end

  context "a warning check" do
    subject { TestThresholdCheck.new(11, 10, 20) }

    it_behaves_like "a healthcheck"

    its(:status) { is_expected.to eq(:warning) }
    its(:message) { is_expected.to match(/above the warning threshold/) }
    its(:details) do
      is_expected.to match(
        hash_including(value: 11, thresholds: { warning: 10, critical: 20 }),
      )
    end
  end

  context "a critical check" do
    subject { TestThresholdCheck.new(21, 10, 20) }

    it_behaves_like "a healthcheck"

    its(:status) { is_expected.to eq(:critical) }
    its(:message) { is_expected.to match(/above the critical threshold/) }
    its(:details) do
      is_expected.to match(
        hash_including(value: 21, thresholds: { warning: 10, critical: 20 }),
      )
    end
  end

  context "with a total" do
    subject { TestThresholdCheck.new(0, 10, 20, 40) }

    it_behaves_like "a healthcheck"

    its(:details) { is_expected.to match(hash_including(total: 40)) }
  end

  class TestThresholdCheck < GovukHealthcheck::ThresholdCheck
    def initialize(value, warning_threshold, critical_threshold, total = nil, name = :test)
      @value = value
      @warning_threshold = warning_threshold
      @critical_threshold = critical_threshold
      @total = total
      @name = name
    end

    attr_reader :value, :warning_threshold, :critical_threshold, :total, :name
  end
end
