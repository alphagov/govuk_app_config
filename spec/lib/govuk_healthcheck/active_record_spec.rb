require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::ActiveRecord do
  let(:active_record) { double(:active_record, connected?: true)}

  before do
    stub_const("ActiveRecord::Base", active_record)
  end

  it_behaves_like "a healthcheck", described_class

  describe ".status" do
    context "when the database is connected" do
      let(:active_record) { double(:active_record, connected?: true)}

      it "returns OK" do
        expect(described_class.status).to eq(GovukHealthcheck::OK)
      end
    end

    context "when the database is not connected" do
      let(:active_record) { double(:active_record, connected?: false)}

      it "returns CRITICAL" do
        expect(described_class.status).to eq(GovukHealthcheck::CRITICAL)
      end
    end
  end
end
