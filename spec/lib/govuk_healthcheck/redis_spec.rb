require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::Redis do
  let(:redis) { double(:redis) }
  let(:redis_client) { double(:redis_client, set: "OK", get: "val", del: 1, close: nil) }

  before do
    stub_const("Redis", redis)
    allow(redis).to receive(:new).and_return(redis_client)
  end

  context "when the database is connected" do
    before { allow(redis_client).to receive(:set) }
    it_behaves_like "a healthcheck"
    it "returns OK" do
      expect(redis_client).to receive(:set).with(anything, anything)
      expect(subject.status).to eq(GovukHealthcheck::OK)
    end
  end

  context "when the database is not connected" do
    before { allow(redis_client).to receive(:set).with(anything, anything).and_raise("error") }
    it_behaves_like "a healthcheck"
    it "returns CRITICAL" do
      expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
    end
  end
end
