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

      expect(Raven).to have_received(:capture_exception).with(StandardError.new, extra: { parameters: "Something"})
    end
  end
end
