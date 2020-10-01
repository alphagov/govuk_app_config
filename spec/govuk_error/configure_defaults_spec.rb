require "spec_helper"
require "govuk_app_config/govuk_error/configure_defaults"

RSpec.describe GovukError::ConfigureDefaults do
  describe ".initialize" do
    it "delegates to the passed object if it doesn't have the method defined" do
      delegated_object = double("Raven.configuration").as_null_object
      expect(delegated_object).to receive(:some_method)
      GovukError::ConfigureDefaults.new(delegated_object).some_method
    end
  end
end
