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
      should_capture=
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

  describe ".should_capture" do
    # mock the PG::Error class so we don't have to pull it in
    module PG; class Error; end; end

    it "passes the 'GOVUK_DATA_SYNC_PERIOD' ENV variable to GovukDataSync, at startup" do
      time_period = "22:30-8:30"
      ClimateControl.modify GOVUK_DATA_SYNC_PERIOD: time_period do
        expect(GovukDataSync).to receive(:new).with(time_period)
        DefaultConfiguration.new(sentry_client)
      end
    end

    it "calls GovukDataSync's .in_progress? method to determine if it should capture error" do
      the_lambda = nil
      allow(sentry_client).to receive(:should_capture=) { |callback| the_lambda = callback }
      govuk_data_sync_instance = double("GovukDataSync instance")
      allow(GovukDataSync).to receive(:new) { govuk_data_sync_instance }

      DefaultConfiguration.new(sentry_client)
      expect(govuk_data_sync_instance).to receive(:in_progress?)
      the_lambda.call(nil)
    end

    it "captures PostgreSQL errors that occur outside of the data sync time window" do
      expect(should_capture(error: PG::Error.new, data_sync_in_progress: false)).to eq(true)
    end

    it "ignores PostgreSQL errors that occur during the data sync time window" do
      expect(should_capture(error: PG::Error.new, data_sync_in_progress: true)).to eq(false)
    end

    it "captures non-PostgreSQL errors that occur during the data sync time window" do
      expect(should_capture(error: StandardError.new, data_sync_in_progress: true)).to eq(true)
    end

    def should_capture(error:, data_sync_in_progress:)
      the_lambda = nil
      allow(sentry_client).to receive(:should_capture=) { |callback| the_lambda = callback }
      govuk_data_sync_instance = double("GovukDataSync instance", in_progress?: data_sync_in_progress)
      allow(GovukDataSync).to receive(:new) { govuk_data_sync_instance }

      DefaultConfiguration.new(sentry_client)
      the_lambda.call(error)
    end
  end
end
