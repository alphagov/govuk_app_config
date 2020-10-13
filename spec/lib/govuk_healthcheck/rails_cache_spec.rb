require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::RailsCache do
  let(:cache) { double(:cache, write: true, read: true) }
  let(:rails) { double(:mongoid, cache: cache) }
  before { stub_const("Rails", rails) }

  describe ".status" do
    context "when the cache is available" do
      it_behaves_like "a healthcheck"

      it "returns OK" do
        expect(subject.status).to eq(GovukHealthcheck::OK)
      end
    end

    context "when the cache is silently unavailable" do
      before do
        allow(cache).to receive(:read) { false }
      end

      it_behaves_like "a healthcheck"

      it "returns CRITICAL" do
        expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
      end
    end

    context "when the cache is loudly unavailable" do
      before do
        allow(cache).to receive(:read) { raise }
      end

      it_behaves_like "a healthcheck"

      it "returns CRITICAL" do
        expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
      end
    end
  end
end
