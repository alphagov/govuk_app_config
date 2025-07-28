require "spec_helper"
require "govuk_app_config/govuk_environment"

RSpec.describe GovukEnvironment do
  describe ".current" do
    it "returns the name of the current environment based on `GOVUK_ENVIRONMENT` env var" do
      ClimateControl.modify GOVUK_ENVIRONMENT: "staging" do
        expect(GovukEnvironment.current).to eq("staging")
      end
    end

    it "defaults to 'development' if no ENV var provided" do
      ClimateControl.modify GOVUK_ENVIRONMENT: nil do
        expect(GovukEnvironment.current).to eq("development")
      end
    end
  end
end
