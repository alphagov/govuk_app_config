require "spec_helper"
require "sentry-ruby"
require "govuk_app_config/govuk_error/configuration"

RSpec.describe GovukError::Configuration do
  before :each do
    stub_const("GovukStatsd", double(Module, increment: nil))
  end

  describe ".initialize" do
    it "delegates to the passed object if it doesn't have the method defined" do
      delegated_object = double("Sentry::Configuration.new").as_null_object
      expect(delegated_object).to receive(:some_method)
      GovukError::Configuration.new(delegated_object).some_method
    end
  end

  describe ".before_send" do
    let(:configuration) do
      configuration = GovukError::Configuration.new(Sentry::Configuration.new)
      configuration.before_send = lambda { |error_or_event, _hint|
        error_or_event
      }
      configuration
    end

    it "ignores errors if they happen in an environment we don't care about" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "some-temporary-environment" do
        configuration.active_sentry_environments << "production"
        sentry_client = send_exception_to_sentry(StandardError.new, configuration)
        expect(sentry_client.transport.events).to be_empty
      end
    end

    it "captures errors if they happen in an environment we care about" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
        configuration.active_sentry_environments << "production"
        sentry_client = send_exception_to_sentry(StandardError.new, configuration)
        expect(sentry_client.transport.events.count).to eq(1)
      end
    end

    it "allows string messages to be sent (rather than exceptions)" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
        configuration.active_sentry_environments << "production"
        configuration.data_sync_excluded_exceptions << "SomeError"
        sentry_client = Sentry::Client.new(optimise_configuration_for_testing(configuration))
        sentry_hub = Sentry::Hub.new(sentry_client, Sentry::Scope.new)

        expect { sentry_hub.capture_message("foo") }
          .to change { sentry_client.transport.events.count }.by(1)
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
        sentry_client = send_exception_to_sentry(StandardError.new, configuration)
        expect(sentry_client.transport.events.count).to eq(1)
      end

      it "should ignore errors that have been added as a string to data_sync_excluded_exceptions" do
        configuration.data_sync_excluded_exceptions << "StandardError"

        sentry_client = send_exception_to_sentry(StandardError.new, configuration)
        expect(sentry_client.transport.events).to be_empty
      end

      it "should ignore errors that have been added as a class to data_sync_excluded_exceptions" do
        configuration.data_sync_excluded_exceptions << StandardError

        sentry_client = send_exception_to_sentry(StandardError.new, configuration)
        expect(sentry_client.transport.events).to be_empty
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
        sentry_client = send_exception_to_sentry(chained_exception, configuration)
        expect(sentry_client.transport.events).to be_empty
      end

      it "should ignore errors that are subclasses of an exception in data_sync_excluded_exceptions" do
        stub_const("SomeClass", Class.new(StandardError))
        stub_const("SomeInheritedClass", Class.new(SomeClass))

        configuration.data_sync_excluded_exceptions << "SomeClass"
        sentry_client = send_exception_to_sentry(SomeInheritedClass.new, configuration)
        expect(sentry_client.transport.events).to be_empty
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

        sentry_client = send_exception_to_sentry(StandardError.new, configuration)
        expect(sentry_client.transport.events.count).to eq(1)
      end
    end

    context "when the before_send lambda has not been overridden" do
      it "increments the appropriate counters" do
        ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
          configuration.active_sentry_environments << "production"
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("errors_occurred")
          expect(GovukStatsd).to receive(:increment).exactly(1).times.with("error_types.standard_error")
          send_exception_to_sentry(StandardError.new, configuration)
        end
      end
    end

    context "when the before_send lambda has been overridden" do
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

          send_exception_to_sentry(StandardError.new, configuration)
        end
      end
    end

    context "when the before_send lambda has been overridden several times, all take effect" do
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

          send_exception_to_sentry(StandardError.new, configuration)
        end
      end
    end
  end

  describe ".before_send=" do
    it "Allows apps to add their own `before_send` callback, that is evaluated alongside the default. If all return their parameter, then the chain continues, but if any returns `nil`, then it ends and the error is dropped" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
        sentry_configurator = GovukError::Configuration.new(Sentry::Configuration.new)
        sentry_configurator.active_sentry_environments << "production"
        stub_const("CustomError", Class.new(StandardError))
        sentry_configurator.before_send = lambda do |event, hint|
          event if hint[:exception].is_a?(CustomError)
        end

        sentry_client = send_exception_to_sentry(CustomError.new, sentry_configurator)
        expect(sentry_client.transport.events.count).to eq(1)
        sentry_client = send_exception_to_sentry(StandardError.new, sentry_configurator)
        expect(sentry_client.transport.events).to be_empty
      end
    end

    it "does not increment the counters if the callback returns nil" do
      ClimateControl.modify SENTRY_CURRENT_ENV: "production" do
        sentry_configurator = GovukError::Configuration.new(Sentry::Configuration.new)
        sentry_configurator.active_sentry_environments << "production"
        sentry_configurator.before_send = lambda do |_error_or_event, _hint|
          nil
        end

        expect(GovukStatsd).not_to receive(:increment).with("errors_occurred")
        expect(GovukStatsd).not_to receive(:increment).with("error_types.standard_error")

        send_exception_to_sentry(StandardError.new, sentry_configurator)
      end
    end
  end

  def send_exception_to_sentry(event, configuration)
    sentry_client = Sentry::Client.new(optimise_configuration_for_testing(configuration))
    sentry_hub = Sentry::Hub.new(sentry_client, Sentry::Scope.new)
    sentry_hub.send(:capture_exception, event)
    sentry_client
  end

  def optimise_configuration_for_testing(configuration)
    # prevent the sending happening in a separate worker, which would cause async results
    configuration.background_worker_threads = 0
    # force configuration to allow sending
    allow(configuration).to receive(:sending_allowed?).and_return(true)
    configuration
  end
end
