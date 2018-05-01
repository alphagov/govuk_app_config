require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqRedis do
  let(:redis_info) { double(:redis_info) }

  before do
    stub_const("Sidekiq", double(:sidekiq, redis_info: redis_info))
  end

  it_behaves_like "a healthcheck", described_class

  context "when the database is connected" do
    let(:redis_info) { double(:redis_info) }

    it "returns OK" do
      expect(described_class.status).to eq(GovukHealthcheck::OK)
    end
  end

  context "when the database is not connected" do
    let(:redis_info) { nil }

    it "returns CRITICAL" do
      expect(described_class.status).to eq(GovukHealthcheck::CRITICAL)
    end
  end
end
