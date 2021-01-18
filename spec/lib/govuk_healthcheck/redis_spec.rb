require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::Redis do
  let(:redis) { double(:redis) }
  let(:redis_client) { double(:redis_client, set: "OK", get: "val", del: 1, close: nil) }

  before do
    stub_const("Redis", redis)
    allow(redis).to receive(:new).and_return(redis_client)
    allow(SecureRandom).to receive(:hex).and_return("abc")
  end

  context "when the database is connected" do
    before do
      allow(redis_client)
        .to receive(:set).with("healthcheck-abc", anything)
    end

    it_behaves_like "a healthcheck"

    it "returns OK" do
      expect(subject.status).to eq(GovukHealthcheck::OK)
    end
  end

  context "when the database is not connected" do
    before do
      allow(redis_client)
        .to receive(:set).with("healthcheck-abc", anything)
        .and_raise("error")
    end

    it_behaves_like "a healthcheck"

    it "returns CRITICAL" do
      expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
    end
  end
end
