require "spec_helper"
require "rails"
require "sentry-raven"
require "govuk_app_config/govuk_error/configure_defaults"

RSpec.describe GovukError::ConfigureDefaults do
  describe ".silence_ready" do
    it "is not set if we are not in a Rails environment" do
      hide_const("Rails")
      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      expect(client.silence_ready).to eq(nil)
    end

    # @TODO - these fail because `defined?(Rails)` returns `nil` for some reason.
    # (Even if we comment out the `hide_const` code above). Very odd.
    #
    # context "we are in a Rails environment" do
    #   let!(:cached_rails_env) { Rails.env }
    #   after { Rails.env = cached_rails_env }
    #
    #   it "is false in production" do
    #     Rails.env = "production"
    #     client = GovukError::ConfigureDefaults.new(Raven.configuration)
    #     expect(client.silence_ready).to eq(false)
    #   end
    #
    #   it "is true when not in production" do
    #     Rails.env = "development"
    #     client = GovukError::ConfigureDefaults.new(Raven.configuration)
    #     expect(client.silence_ready).to eq(true)
    #   end
    # end
  end

  describe ".should_capture" do
    # mock the PG::Error class so we don't have to pull it in
    module PG; class Error; end; end

    it "passes the 'GOVUK_DATA_SYNC_PERIOD' ENV variable to GovukDataSync, at startup" do
      time_period = "22:30-8:30"
      ClimateControl.modify GOVUK_DATA_SYNC_PERIOD: time_period do
        expect(GovukDataSync).to receive(:new).with(time_period)
        GovukError::ConfigureDefaults.new(Raven.configuration)
      end
    end

    it "calls GovukDataSync's .in_progress? method to determine if it should capture error" do
      govuk_data_sync_instance = double("GovukDataSync instance")
      allow(GovukDataSync).to receive(:new) { govuk_data_sync_instance }
      expect(govuk_data_sync_instance).to receive(:in_progress?)

      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      client.should_capture.call(nil)
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
      govuk_data_sync_instance = double("GovukDataSync instance", in_progress?: data_sync_in_progress)
      allow(GovukDataSync).to receive(:new) { govuk_data_sync_instance }

      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      client.should_capture.call(error)
    end
  end
end
