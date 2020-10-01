require "spec_helper"
require "rails"
require "govuk_app_config/default_configuration"

RSpec.describe DefaultConfiguration do
  let(:sentry_client) do
    methods_to_stub = %w[
      before_send=
      silence_ready=
      excluded_exceptions=
      inspect_exception_causes_for_exclusion=
      transport_failure_callback=
    ]
    dbl = double("Raven")
    methods_to_stub.each { |method| allow(dbl).to receive(method.to_sym) }
    dbl
  end

  describe ".silence_ready" do
    it "is not set if we are not in a Rails environment" do
      hide_const("Rails")
      expect(sentry_client).to_not receive(:silence_ready=)
      DefaultConfiguration.new(sentry_client)
    end

    context "we are in a Rails environment" do
      let!(:cached_rails_env) { Rails.env }
      after { Rails.env = cached_rails_env }

      it "is false in production" do
        Rails.env = "production"
        expect(sentry_client).to receive(:silence_ready=).with(false)
        DefaultConfiguration.new(sentry_client)
      end

      it "is true when not in production" do
        Rails.env = "development"
        expect(sentry_client).to receive(:silence_ready=).with(true)
        DefaultConfiguration.new(sentry_client)
      end
    end
  end
end
