require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::EmergencyBannerRedis do
  let(:redis) { double(:redis) }
  let(:redis_client) { double(:redis_client, set: "OK", get: "val", del: 1, close: nil) }
  let(:redis_url) { "redis://emergency-banner/1" }
  let(:redis_bad_url) { "redis://BAD_URL/1" }
  let(:redis_bad_client) { double }

  before do
    stub_const("Redis", redis)
    allow(redis).to receive(:new).with(url: redis_url, reconnect_attempts: anything).and_return(redis_client)
    allow(redis).to receive(:new).with(url: redis_bad_url, reconnect_attempts: anything).and_return(redis_bad_client)
    allow(redis_bad_client).to receive(:set).and_raise
    allow(redis_bad_client).to receive(:get).and_raise
    allow(redis_bad_client).to receive(:del).and_raise
    allow(redis_bad_client).to receive(:close).and_raise
    allow(SecureRandom).to receive(:hex).and_return("abc")
  end

  context "when redis is available" do
    around(:example) do |example|
      ClimateControl.modify EMERGENCY_BANNER_REDIS_URL: redis_url do
        example.run
      end
    end

    before do
      allow(redis_client)
        .to receive(:set).with("healthcheck-abc", anything)
    end

    it_behaves_like "a healthcheck"

    it "returns OK" do
      expect(subject.status).to eq(GovukHealthcheck::OK)
    end
  end

  context "when redis is not available" do
    around(:example) do |example|
      ClimateControl.modify EMERGENCY_BANNER_REDIS_URL: redis_bad_url do
        example.run
      end
    end

    it_behaves_like "a healthcheck"

    it "returns CRITICAL" do
      expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
    end
  end
end
