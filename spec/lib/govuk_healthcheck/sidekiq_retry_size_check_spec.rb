require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqRetrySizeCheck do
  subject { TestRetrySizeCheck.new }

  let(:sidekiq_stats) { double(retry_size: 10) }
  let(:sidekiq_stats_class) { double }

  before do
    allow(sidekiq_stats_class).to receive(:new).and_return(sidekiq_stats)
    stub_const("Sidekiq::Stats", sidekiq_stats_class)
  end

  it_behaves_like "a healthcheck"

  class TestRetrySizeCheck < GovukHealthcheck::SidekiqRetrySizeCheck
    def warning_threshold
      10
    end

    def critical_threshold
      20
    end
  end
end
