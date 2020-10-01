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

  describe ".should_capture=" do
    it "Allows apps to add their own `should_capture` callback, that is evaluated alongside the default. If both return `true`, then we should capture, but if either returns `false`, then we shouldn't." do
      class DefaultErrorToIgnore < StandardError; end
      class CustomErrorToIgnore < StandardError; end

      raven_configurator = GovukError::RavenDelegator.new(Raven.configuration)
      raven_configurator.should_capture = lambda do |error_or_event|
        !error_or_event.is_a?(DefaultErrorToIgnore)
      end
      raven_configurator.should_capture = lambda do |error_or_event|
        !error_or_event.is_a?(CustomErrorToIgnore)
      end

      expect(raven_configurator.should_capture.call(DefaultErrorToIgnore.new)).to eq(false)
      expect(raven_configurator.should_capture.call(CustomErrorToIgnore.new)).to eq(false)
      expect(raven_configurator.should_capture.call(StandardError.new)).to eq(true)
    end
  end
end
