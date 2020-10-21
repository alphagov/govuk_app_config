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

  describe ".should_capture" do
    context "during the data sync" do
      around do |example|
        ClimateControl.modify GOVUK_DATA_SYNC_PERIOD: "22:00-08:00" do
          travel_to(Time.current.change(hour: 23)) do
            example.run
          end
        end
      end

      let(:configuration) { GovukError::Configuration.new(Raven.configuration) }

      it "should capture errors by default" do
        expect(configuration.should_capture.call(StandardError.new)).to eq(true)
      end

      it "should ignore errors that have been added to data_sync_excluded_exceptions" do
        configuration.data_sync_excluded_exceptions << "StandardError"

        expect(configuration.should_capture.call(StandardError.new)).to eq(false)
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
        expect(configuration.should_capture.call(chained_exception)).to eq(false)
      end

      it "should ignore errors that are subclasses of an exception in data_sync_excluded_exceptions" do
        stub_const("SomeClass", Class.new(StandardError))
        stub_const("SomeInheritedClass", Class.new(SomeClass))

        configuration.data_sync_excluded_exceptions << "SomeClass"
        expect(configuration.should_capture.call(SomeInheritedClass.new)).to eq(false)
      end
    end
  end

  describe ".should_capture=" do
    it "Allows apps to add their own `should_capture` callback, that is evaluated alongside the default. If both return `true`, then we should capture, but if either returns `false`, then we shouldn't." do
      raven_configurator = GovukError::Configuration.new(Raven.configuration)
      raven_configurator.should_capture = lambda do |error_or_event|
        error_or_event == "do capture"
      end

      expect(raven_configurator.should_capture.call("do capture")).to eq(true)
      expect(raven_configurator.should_capture.call("don't capture")).to eq(false)
    end
  end
end
