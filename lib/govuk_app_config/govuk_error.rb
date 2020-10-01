require "sentry-raven"
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/govuk_error/raven_delegator"

module GovukError
  def self.notify(exception_or_message, args = {})
    # Allow users to use `parameters` as a key like the Airbrake
    # client, allowing easy upgrades.
    args[:extra] ||= {}
    args[:extra].merge!(parameters: args.delete(:parameters))

    Raven.capture_exception(exception_or_message, args)
  end

  def self.configure
    yield RavenDelegator.new(Raven.configuration)
  end
end
