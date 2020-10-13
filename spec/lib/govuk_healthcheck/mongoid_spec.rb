require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::Mongoid do
  let(:client) { double(:client, database_names: %w[db]) }
  let(:mongoid) { double(:mongoid, default_client: client) }
  before { stub_const("Mongoid", mongoid) }

  describe ".status" do
    context "when the database is connected" do
      it_behaves_like "a healthcheck"

      it "returns OK" do
        expect(subject.status).to eq(GovukHealthcheck::OK)
      end
    end

    context "when the database is not connected" do
      before do
        allow(client).to receive(:database_names) { raise }
      end

      it_behaves_like "a healthcheck"

      it "returns CRITICAL" do
        expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
      end
    end
  end
end
