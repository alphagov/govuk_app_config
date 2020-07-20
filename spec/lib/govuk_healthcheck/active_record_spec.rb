require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::ActiveRecord do
  let(:active_record) { double(:active_record, connected?: true) }
  before { stub_const("ActiveRecord::Base", active_record) }

  describe ".status" do
    context "when the database is connected" do
      let(:active_record) { double(:active_record, connection: true) }

      it_behaves_like "a healthcheck"

      it "returns OK" do
        expect(subject.status).to eq(GovukHealthcheck::OK)
      end
    end

    context "when the database is not connected" do
      let(:active_record) { double(:active_record, connection: true) }

      before do
        allow(active_record).to receive(:connection) { raise }
      end

      it_behaves_like "a healthcheck"

      it "returns CRITICAL" do
        expect(subject.status).to eq(GovukHealthcheck::CRITICAL)
      end
    end
  end
end
