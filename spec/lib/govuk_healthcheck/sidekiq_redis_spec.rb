require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqRedis do
  let(:redis_info) { double(:redis_info) }
  before { stub_const("Sidekiq", double(:sidekiq, redis_info: redis_info)) }

  context "when the database is connected" do
    let(:redis_info) { double(:redis_info) }

    it_behaves_like "a healthcheck"

    it "returns OK" do
      expect(subject.status).to eq(GovukHealthcheck::OK)
    end
  end

  context "when the database is not connected" do
    let(:redis_info) { nil }

    it_behaves_like "a healthcheck"

    it "returns CRITICAL" do
      expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
    end
  end
end
