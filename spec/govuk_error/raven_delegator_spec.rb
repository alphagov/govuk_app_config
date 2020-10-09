require "spec_helper"
require "sentry-raven"
require "govuk_app_config/govuk_error/raven_delegator"

RSpec.describe GovukError::RavenDelegator do
  describe ".initialize" do
    it "delegates to the passed object if it doesn't have the method defined" do
      delegated_object = double("Raven.configuration").as_null_object
      expect(delegated_object).to receive(:some_method)
      GovukError::RavenDelegator.new(delegated_object).some_method
    end
  end

  describe ".should_capture" do
    around do |example|
      ClimateControl.modify GOVUK_DATA_SYNC_PERIOD: "22:00-08:00" do
        example.run
      end
    end

    let(:raven_delegator) do
      client = GovukError::RavenDelegator.new(Raven.configuration)
      client.data_sync_excluded_exceptions << "PG::Error"
      client
    end

    it "should ignore PostgreSQL errors that occur during the data sync" do
      pg_error = double("PG::Error", class: "PG::Error")
      travel_to(Time.current.change(hour: 23)) do
        expect(raven_delegator.should_capture.call(pg_error)).to eq(false)
      end
    end

    it "should ignore exceptions whose underlying cause is a PostgreSQL error, during the data sync" do
      pg_error = double("Caused by PG::Error", class: "PG::Error")
      exception = double("Exception 1", cause: double("Exception 2", cause: pg_error))
      allow(pg_error).to receive(:cause)
      travel_to(Time.current.change(hour: 23)) do
        expect(raven_delegator.should_capture.call(exception)).to eq(false)
      end
    end

    it "should capture PostgreSQL errors that occur outside the data sync" do
      pg_error = double("PG::Error", class: "PG::Error")
      travel_to(Time.current.change(hour: 18)) do
        expect(raven_delegator.should_capture.call(pg_error)).to eq(true)
      end
    end

    it "should capture non-PostgreSQL errors that occur during the data sync" do
      travel_to(Time.current.change(hour: 23)) do
        expect(raven_delegator.should_capture.call(StandardError.new)).to eq(true)
      end
    end

    it "should ignore errors that have been added to data_sync_excluded_exceptions, if they occurred during the data sync" do
      client = raven_delegator
      client.data_sync_excluded_exceptions << "StandardError"

      travel_to(Time.current.change(hour: 23)) do
        expect(client.should_capture.call(StandardError.new)).to eq(false)
      end
    end
  end

  describe ".should_capture=" do
    it "Allows apps to add their own `should_capture` callback, that is evaluated alongside the default. If both return `true`, then we should capture, but if either returns `false`, then we shouldn't." do
      raven_configurator = GovukError::RavenDelegator.new(Raven.configuration)
      raven_configurator.should_capture = lambda do |error_or_event|
        error_or_event == "do capture"
      end

      expect(raven_configurator.should_capture.call("do capture")).to eq(true)
      expect(raven_configurator.should_capture.call("don't capture")).to eq(false)
    end
  end
end
