require "spec_helper"
require "govuk_app_config/govuk_healthcheck"
require_relative "shared_interface"

RSpec.describe GovukHealthcheck::ActiveRecord do
  module ActiveRecord
    module Base
      def self.connected?
        true
      end
    end
  end

  it_behaves_like "a healthcheck", described_class

  context "when the database is connected" do
    before do
      allow(ActiveRecord::Base).to receive(:connected?).and_return(true)
    end

    it "returns OK" do
      expect(described_class.status).to eq(GovukHealthcheck::OK)
    end
  end

  context "when the database is not connected" do
    before do
      allow(ActiveRecord::Base).to receive(:connected?).and_return(false)
    end

    it "returns CRITICAL" do
      expect(described_class.status).to eq(GovukHealthcheck::CRITICAL)
    end
  end
end
