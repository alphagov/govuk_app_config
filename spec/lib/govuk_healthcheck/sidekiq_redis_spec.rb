require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::SidekiqRedis do
  before { stub_const("Sidekiq", sidekiq) }

  context "when Sidekiq responds to '.default_configuration'" do
    let(:redis_info) { double(:redis_info) }
    let(:default_configuration) { double(:default_configuration, redis_info:) }
    let(:sidekiq) { double(:sidekiq, default_configuration:) }

    context "and the database is connected" do
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

    context "and redis raises a connection error" do
      it "returns CRITICAL" do
        allow(default_configuration).to receive(:redis_info).and_raise StandardError

        expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
      end
    end
  end

  context "when Sidekiq doesn't respond to '.default_configuration'" do
    let(:redis_info) { double(:redis_info) }
    let(:sidekiq) { double(:sidekiq, redis_info:) }

    context "and the database is connected" do
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

    context "and redis raises a connection error" do
      it "returns CRITICAL" do
        allow(sidekiq).to receive(:redis_info).and_raise StandardError

        expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
      end
    end
  end
end
