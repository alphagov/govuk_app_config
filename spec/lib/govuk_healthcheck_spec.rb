require "spec_helper"
require "govuk_app_config/govuk_healthcheck"

RSpec.describe GovukHealthcheck do
  describe "#rack_response" do
    let(:response) { described_class.rack_response.call }

    it "sets the content type" do
      expect(response[1].fetch("Content-Type")).to eq("application/json")
    end
  end
end
