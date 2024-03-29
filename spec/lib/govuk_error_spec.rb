require "spec_helper"
require "govuk_app_config/govuk_error"

RSpec.describe GovukError do
  describe ".notify" do
    before do
      # Call original on these to ensure we discover any problems with the method interfaces
      allow(Sentry).to receive(:capture_exception).and_call_original
      allow(Sentry).to receive(:capture_message).and_call_original
    end

    it "forwards the exception" do
      GovukError.notify(StandardError.new)
      expect(Sentry).to have_received(:capture_exception)
    end

    it "forwards the string" do
      GovukError.notify("Foo")
      expect(Sentry).to have_received(:capture_message)
    end

    it "allows Airbrake-style parameters" do
      GovukError.notify(StandardError.new, parameters: "Something")
      expect(Sentry).to have_received(:capture_exception).with(StandardError.new, hash_including(extra: { parameters: "Something" }))
    end

    it "sends the version along with the request" do
      GovukError.notify(StandardError.new, parameters: "Something")
      expect(Sentry).to have_received(:capture_exception).with(StandardError.new, hash_including(tags: { govuk_app_config_version: /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(\.pre\.[0-9]+)?$/ }))
    end
  end

  describe ".configure" do
    it "configures Sentry via the Configuration, and raises exception for subsequent calls" do
      allow(Sentry).to receive(:get_current_client).and_return(nil)
      expect { |b| GovukError.configure(&b) }
        .to yield_with_args(instance_of(GovukError::Configuration))

      allow(Sentry).to receive(:get_current_client).and_return(double("Sentry::Client"))
      expect { GovukError.configure { |_config| } }
        .to raise_exception(GovukError::AlreadyInitialised)
    end

    it "raises a warning if Sidekiq exists but Sidekiq::Sentry does not" do
      stub_const("Sidekiq", "Sidekiq")
      allow(Sentry).to receive(:get_current_client).and_return(nil)

      expect { GovukError.configure }
        .to output(/Warning: GovukError is not configured to track Sidekiq errors/).to_stderr
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
