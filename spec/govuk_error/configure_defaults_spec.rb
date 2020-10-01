require "spec_helper"
require "rails"
require "sentry-raven"
require "govuk_app_config/govuk_error/configure_defaults"

RSpec.describe GovukError::ConfigureDefaults do
  around do |example|
    ClimateControl.modify GOVUK_DATA_SYNC_PERIOD: "22:00-08:00" do
      example.run
    end
  end

  describe ".initialize" do
    it "delegates to the passed object if it doesn't have the method defined" do
      delegated_object = double("Raven.configuration").as_null_object
      expect(delegated_object).to receive(:some_method)
      GovukError::ConfigureDefaults.new(delegated_object).some_method
    end
  end

  describe ".silence_ready" do
    it "is not set if we are not in a Rails environment" do
      hide_const("Rails")
      delegated_object = double("Raven.configuration").as_null_object
      expect(delegated_object).not_to receive(:silence_ready=)
      GovukError::ConfigureDefaults.new(delegated_object)
    end

    context "we are in a Rails environment" do
      it "is true when not in production" do
        delegated_object = double("Raven.configuration").as_null_object
        expect(delegated_object).to receive(:silence_ready=).with(true)
        GovukError::ConfigureDefaults.new(delegated_object)
      end

      it "is false in production" do
        # rubocop:disable Naming/ConstantName
        cached_rails = Rails
        Rails = class_double("Rails", env: double("env", production?: true))
        delegated_object = double("Raven.configuration").as_null_object
        expect(delegated_object).to receive(:silence_ready=).with(false)
        GovukError::ConfigureDefaults.new(delegated_object)
        Rails = cached_rails
        # rubocop:enable Naming/ConstantName
      end
    end
  end

  describe ".should_capture" do
    it "should ignore PostgreSQL errors that occur during the data sync" do
      pg_error = double("PG::Error", class: "PG::Error")
      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      travel_to(Time.current.change(hour: 23)) do
        expect(client.should_capture.call(pg_error)).to eq(false)
      end
    end

    it "should ignore exceptions whose underlying cause is a PostgreSQL error, during the data sync" do
      pg_error = double("Caused by PG::Error", class: "PG::Error")
      exception = double("Exception 1", cause: double("Exception 2", cause: pg_error))
      allow(pg_error).to receive(:cause)
      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      travel_to(Time.current.change(hour: 23)) do
        expect(client.should_capture.call(exception)).to eq(false)
      end
    end

    it "should capture PostgreSQL errors that occur outside the data sync" do
      pg_error = double("PG::Error", class: "PG::Error")
      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      travel_to(Time.current.change(hour: 18)) do
        expect(client.should_capture.call(pg_error)).to eq(true)
      end
    end

    it "should capture non-PostgreSQL errors that occur during the data sync" do
      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      travel_to(Time.current.change(hour: 23)) do
        expect(client.should_capture.call(StandardError.new)).to eq(true)
      end
    end

    it "should ignore errors that have been added to data_sync_excluded_exceptions, if they occurred during the data sync" do
      client = GovukError::ConfigureDefaults.new(Raven.configuration)
      client.data_sync_excluded_exceptions << "StandardError"

      travel_to(Time.current.change(hour: 23)) do
        expect(client.should_capture.call(StandardError.new)).to eq(false)
      end
    end
  end
end
