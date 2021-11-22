require "spec_helper"
require "govuk_app_config/govuk_cache"

RSpec.describe GovukCache do
  describe "FRONTEND_EXPIRY_SECONDS" do
    it "returns 300 seconds" do
      expect(described_class::FRONTEND_EXPIRY_SECONDS).to eq(300)
    end
  end
end
