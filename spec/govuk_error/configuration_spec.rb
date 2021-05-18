require "spec_helper"
require "sentry-raven"
require "govuk_app_config/govuk_error/configuration"

RSpec.describe GovukError::Configuration do
  describe ".initialize" do
    it "delegates to the passed object if it doesn't have the method defined" do
      delegated_object = double("Raven.configuration").as_null_object
      expect(delegated_object).to receive(:some_method)
      GovukError::Configuration.new(delegated_object).some_method
    end
  end

  describe ".before_send" do
    let(:configuration) { GovukError::Configuration.new(Raven.configuration) }

    it "ignores errors if they happen in an environment we don't care about" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "some-temporary-environment" do
        configuration.active_sentry_environments << "production"
        expect(configuration.before_send.call(StandardError.new)).to be_nil
      end
    end

    it "captures errors if they happen in an environment we care about" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
        configuration.active_sentry_environments << "production"
        expect(configuration.before_send.call(StandardError.new)).to be_truthy
      end
    end

    context "during the data sync" do
      around do |example|
        ClimateControl.modify SENTRY_CURRENT_ENV: "production", GOVUK_DATA_SYNC_PERIOD: "22:00-08:00" do
          configuration.active_sentry_environments << "production"
          travel_to(Time.current.change(hour: 23)) do
            example.run
          end
        end
      end

      it "should capture errors by default" do
        expect(configuration.before_send.call(StandardError.new)).to be_truthy
      end

      it "should ignore errors that have been added as a string to data_sync_excluded_exceptions" do
        configuration.data_sync_excluded_exceptions << "StandardError"

        expect(configuration.before_send.call(StandardError.new)).to be_nil
      end

      it "should ignore errors that have been added as a class to data_sync_excluded_exceptions" do
        configuration.data_sync_excluded_exceptions << StandardError

        expect(configuration.before_send.call(StandardError.new)).to be_nil
      end

      it "should ignore errors whose underlying cause is an exception in data_sync_excluded_exceptions" do
        stub_const("ErrorWeCareAbout", Class.new(StandardError))
        stub_const("SomeOtherError", Class.new(StandardError))
        configuration.data_sync_excluded_exceptions << "ErrorWeCareAbout"

        chained_exception = nil
        begin
          begin
            raise ErrorWeCareAbout
          rescue ErrorWeCareAbout
            raise SomeOtherError
          end
        rescue SomeOtherError => e
          chained_exception = e
        end

        expect(chained_exception).to be_an_instance_of(SomeOtherError)
        expect(configuration.before_send.call(chained_exception)).to be_nil
      end

      it "should ignore errors that are subclasses of an exception in data_sync_excluded_exceptions" do
        stub_const("SomeClass", Class.new(StandardError))
        stub_const("SomeInheritedClass", Class.new(SomeClass))

        configuration.data_sync_excluded_exceptions << "SomeClass"
        expect(configuration.before_send.call(SomeInheritedClass.new)).to be_nil
      end
    end

    context "outside of the data sync" do
      around do |example|
        ClimateControl.modify SENTRY_CURRENT_ENV: "production", GOVUK_DATA_SYNC_PERIOD: "22:00-08:00" do
          configuration.active_sentry_environments << "production"
          travel_to(Time.current.change(hour: 21)) do
            example.run
          end
        end
      end

      it "should capture errors even if they are in the list of data_sync_excluded_exceptions" do
        configuration.data_sync_excluded_exceptions << "StandardError"

        expect(configuration.before_send.call(StandardError.new)).to be_truthy
      end
    end

    context "when the before_send lambda has not been overridden" do
      before { stub_const("GovukStatsd", double(Module)) }
      it "increments the appropriate counters" do
        ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
          configuration.active_sentry_environments << "production"
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("errors_occurred")
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("error_types.standard_error")
          configuration.before_send.call(StandardError.new)
        end
      end
    end

    context "when the before_send lambda has been overridden" do
      before { stub_const("GovukStatsd", double(Module)) }
      it "increments the appropriate counters" do
        ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
          configuration.active_sentry_environments << "production"
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("errors_occurred")
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("error_types.standard_error")
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("hello_world")

          configuration.before_send = lambda do |error_or_event, _hint|
            GovukStatsd.increment("hello_world")
            error_or_event
          end

          configuration.before_send.call(StandardError.new)
        end
      end
    end

    context "when the before_send lambda has been overridden several times, all take effect" do
      before { stub_const("GovukStatsd", double(Module)) }
      it "increments the appropriate counters" do
        ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
          configuration.active_sentry_environments << "production"
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("errors_occurred")
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("error_types.standard_error")
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("hello_world")
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("hello_world_again")

          configuration.before_send = lambda do |error_or_event, _hint|
            GovukStatsd.increment("hello_world")
            error_or_event
          end
          configuration.before_send = lambda do |error_or_event, _hint|
            GovukStatsd.increment("hello_world_again")
            error_or_event
          end

          configuration.before_send.call(StandardError.new)
        end
      end
    end
  end

  describe ".before_send=" do
    it "Allows apps to add their own `before_send` callback, that is evaluated alongside the default. If all return their parameter, then the chain continues, but if any returns `nil`, then it ends and the error is dropped" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
        raven_configurator = GovukError::Configuration.new(Raven.configuration)
        raven_configurator.active_sentry_environments << "production"
        raven_configurator.before_send = lambda do |error_or_event, _hint|
          error_or_event if error_or_event == "do capture"
        end

        expect(raven_configurator.before_send.call("do capture")).to be_truthy
        expect(raven_configurator.before_send.call("don't capture", {})).to be_nil
      end
    end

    it "does not increment the counters if the callback returns nil" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
        raven_configurator = GovukError::Configuration.new(Raven.configuration)
        raven_configurator.active_sentry_environments << "production"
        raven_configurator.before_send = lambda do |_error_or_event, _hint|
          nil
        end

        expect(GovukStatsd).not_to receive(:increment).with("errors_occurred")
        expect(GovukStatsd).not_to receive(:increment).with("error_types.standard_error")

        raven_configurator.before_send.call(StandardError.new)
      end
    end
  end
end
