require "spec_helper"
require "govuk_app_config/govuk_error"

RSpec.describe GovukError do
  describe ".notify" do
    it "forwards the exception" do
      allow(Sentry).to receive(:capture_exception)

      GovukError.notify(StandardError.new)

      expect(Sentry).to have_received(:capture_exception)
    end

    it "allows Airbrake-style parameters" do
      allow(Sentry).to receive(:capture_exception)

      GovukError.notify(StandardError.new, parameters: "Something")

      expect(Sentry).to have_received(:capture_exception).with(StandardError.new, hash_including(extra: { parameters: "Something" }))
    end

    it "sends the version along with the request" do
      allow(Sentry).to receive(:capture_exception)

      GovukError.notify(StandardError.new, parameters: "Something")

      expect(Sentry).to have_received(:capture_exception).with(StandardError.new, hash_including(tags: { govuk_app_config_version: /^[0-9]\.[0-9]\.[0-9](?:\.pre\.[0-9]+)?$/ }))
    end
  end

  describe ".configure" do
    it "configures Sentry via the Configuration" do
      expect { |b| GovukError.configure(&b) }
        .to yield_with_args(instance_of(GovukError::Configuration))
    end
  end
end
