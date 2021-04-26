require "spec_helper"
require "govuk_app_config/govuk_healthcheck"

RSpec.describe GovukHealthcheck do
  describe "#rack_response" do
    let(:active_record) { double(:active_record, connected?: true, connection: true) }
    before { stub_const("ActiveRecord::Base", active_record) }

    let(:response) { described_class.rack_response(GovukHealthcheck::ActiveRecord).call }

    it "sets the content type" do
      expect(response[1].fetch("Content-Type")).to eq("application/json")
    end

    it "returns a 200 status code" do
      expect(response[0]).to eq(200)
    end

    context "a check fails" do
      before do
        allow(active_record).to receive(:connection) { raise }
      end

      it "returns a 500 status code" do
        expect(response[0]).to eq(500)
      end
    end
  end
end
