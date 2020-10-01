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
    before :each do
      allow(GovukDataSync).to receive(:new) { govuk_data_sync_instance }
    end

    let!(:govuk_data_sync_instance) { double("GovukDataSync instance") }

    it "passes the 'GOVUK_DATA_SYNC_PERIOD' ENV variable to GovukDataSync, at startup" do
      time_period = "22:30-8:30"
      ClimateControl.modify GOVUK_DATA_SYNC_PERIOD: time_period do
        expect(GovukDataSync).to receive(:new).with(time_period)
        GovukError::ConfigureDefaults.new(Raven.configuration)
      end
    end

    it "calls GovukDataSync's .in_progress? method to determine if it should capture error" do
      expect(govuk_data_sync_instance).to receive(:in_progress?)

      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      client.should_capture.call(nil)
    end

    context "outside the data sync time window" do
      before { allow(govuk_data_sync_instance).to receive(:in_progress?) { false } }

      it "captures PostgreSQL errors" do
        pg_error = double("PG::Error", class: "PG::Error")
        client = GovukError::ConfigureDefaults.new(Raven.configuration)
        expect(client.should_capture.call(pg_error)).to eq(true)
      end
    end

    context "during the data sync time window" do
      before { allow(govuk_data_sync_instance).to receive(:in_progress?) { true } }

      it "ignores PostgreSQL errors" do
        pg_error = double("PG::Error", class: "PG::Error")
        client = GovukError::ConfigureDefaults.new(Raven.configuration)
        expect(client.should_capture.call(pg_error)).to eq(false)
      end

      it "ignores PostgreSQL errors that have deep exception cause chains" do
        pg_error = double("Caused by PG::Error", class: "PG::Error")
        exception = double("Exception 1", cause: double("Exception 2", cause: pg_error))
        allow(pg_error).to receive(:cause)
        client = GovukError::ConfigureDefaults.new(Raven.configuration)
        expect(client.should_capture.call(exception)).to eq(false)
      end

      it "captures non-PostgreSQL errors" do
        client = GovukError::ConfigureDefaults.new(Raven.configuration)
        expect(client.should_capture.call(StandardError.new)).to eq(true)
      end

      it "ignores non-PostgreSQL errors that have been added to data_sync_excluded_exceptions" do
        client = GovukError::ConfigureDefaults.new(Raven.configuration)
        client.data_sync_excluded_exceptions << "StandardError"
        expect(client.should_capture.call(StandardError.new)).to eq(false)
      end
    end
  end
end
