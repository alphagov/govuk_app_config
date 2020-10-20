require "spec_helper"
require "govuk_app_config/govuk_error/custom_fingerprint"

RSpec.describe GovukError::CustomFingerprint do
  describe ".sample" do
    # See https://www.rubydoc.info/gems/sentry-raven/Raven/Event
    it "takes a Raven::Event as a parameter and returns an array" do
      event = double("Raven::Event")
      fingerprint = GovukError::CustomFingerprint.sample(event)
      expect(fingerprint).to be_an_instance_of(Array)
    end

    # As you can see below, we'd be adding complexity to govuk_app_config
    # by deviating from the defaults.
    # An alternative is to stick with the default fingerprinting metric,
    # but use server side fingerprinting, but this has to be configured in
    # the Sentry UI itself.
    # https://docs.sentry.io/platforms/ruby/data-management/event-grouping/server-side-fingerprinting/

    it "matches by stack trace in the first instance" do
      # TODO
    end

    it "uses a stack trace that only includes 'application frames'" do
      # TODO
    end

    it "matches by error name and transaction if stack trace is unavailable (either missing to begin with, or after being stripped of 'framework frames'" do
      # TODO
    end
  end
end
