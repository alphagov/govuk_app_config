require "sentry-raven"
require "govuk_app_config/govuk_error/configuration"
require "govuk_app_config/govuk_statsd"

module GovukError
  def self.notify(exception_or_message, args = {})
    # Allow users to use `parameters` as a key like the Airbrake
    # client, allowing easy upgrades.
    args[:extra] ||= {}
    args[:extra].merge!(parameters: args.delete(:parameters))

    Raven.capture_exception(exception_or_message, args)
  end

  def self.init
    @raven_configuration = Configuration.new(Raven.configuration)
  end

  def self.configure
    yield @raven_configuration
  end
end
