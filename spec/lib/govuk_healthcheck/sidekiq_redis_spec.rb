require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqRedis do
  module Sidekiq
    def self.redis_info
      true
    end
  end

  it_behaves_like "a healthcheck", described_class

  context "when the database is connected" do
    before do
      allow(Sidekiq).to receive(:redis_info).and_return(double(:redis_info))
    end

    it "returns OK" do
      expect(described_class.status).to eq(GovukHealthcheck::OK)
    end
  end

  context "when the database is not connected" do
    before do
      allow(Sidekiq).to receive(:redis_info).and_return(nil)
    end

    it "returns CRITICAL" do
      expect(described_class.status).to eq(GovukHealthcheck::CRITICAL)
    end
  end
end
