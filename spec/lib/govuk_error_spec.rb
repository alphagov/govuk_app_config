require "spec_helper"
require "govuk_app_config/govuk_error"

RSpec.describe GovukError do
  before do
    GovukError.init
  end

  describe ".notify" do
    it "forwards the exception" do
      allow(Raven).to receive(:capture_exception)

      GovukError.notify(StandardError.new)

      expect(Raven).to have_received(:capture_exception)
    end

    it "allows Airbrake-style parameters" do
      allow(Raven).to receive(:capture_exception)

      GovukError.notify(StandardError.new, parameters: "Something")

      expect(Raven).to have_received(:capture_exception).with(StandardError.new, extra: { parameters: "Something" })
    end
  end

  describe ".configure" do
    it "raises an error if you attempt to configure something unrecognised" do
      expect {
        GovukError.configure do |config|
          config.unrecognised_thing = "some value"
        end
      }.to raise_error NoMethodError
    end

    it "allows apps to add to the excluded exceptions" do
      custom_error = "DeliveryRequestWorker::ProviderCommunicationFailureError"
      GovukError.configure do |config|
        config.excluded_exceptions << custom_error
      end
      expect(Raven.configuration.excluded_exceptions).to include(custom_error)
    end
  end
end
