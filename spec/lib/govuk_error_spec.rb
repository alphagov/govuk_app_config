require "spec_helper"
require "govuk_app_config/govuk_error"

RSpec.describe GovukError do
  describe ".notify" do
    it "forwards the exception" do
      allow(Sentry).to receive(:capture_exception)

      GovukError.notify(StandardError.new)

      expect(Sentry).to have_received(:capture_exception)
    end

    it "forwards the string" do
      allow(Sentry).to receive(:capture_message)

      GovukError.notify("Foo")

      expect(Sentry).to have_received(:capture_message)
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
    it "configures Sentry via the Configuration, and raises exception for subsequent calls" do
      expect { |b| GovukError.configure(&b) }
        .to yield_with_args(instance_of(GovukError::Configuration))

      expect { GovukError.configure { |_config| } }
        .to raise_exception(GovukError::AlreadyInitialised)
    end
  end

  describe ".is_configured?" do
    it "returns false if not configured" do
      allow(Sentry).to receive(:get_current_client).and_return(nil)

      expect(GovukError.is_configured?).to eq(false)
    end

    it "returns true if configured" do
      allow(Sentry).to receive(:get_current_client).and_return(double("Sentry::Client"))

      expect(GovukError.is_configured?).to eq(true)
    end
  end
end
