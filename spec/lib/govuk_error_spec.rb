require "spec_helper"
require "govuk_app_config/govuk_error"

RSpec.describe GovukError do
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
    it "configures Raven via the RavenDelegator" do
      mock_raven_delegator = double("RavenDelegator")
      allow(GovukError::RavenDelegator).to receive(:new) { mock_raven_delegator }
      expect(mock_raven_delegator).to receive(:foo)
      GovukError.configure(&:foo)
    end
  end
end
