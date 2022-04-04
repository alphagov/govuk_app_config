require "sentry-ruby"
require "sentry-rails" if defined?(Rails)
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/govuk_error/configuration"
require "govuk_app_config/version"

module GovukError
  class AlreadyInitialised < StandardError
    def initialize(msg = "You can only call GovukError.configure once!")
      super
    end
  end

  def self.notify(exception_or_message, args = {})
    # Allow users to use `parameters` as a key like the Airbrake
    # client, allowing easy upgrades.
    args[:extra] ||= {}
    args[:extra].merge!(parameters: args.delete(:parameters))

    args[:tags] ||= {}
    args[:tags][:govuk_app_config_version] = GovukAppConfig::VERSION

    if exception_or_message.is_a?(String)
      Sentry.capture_message(exception_or_message, args)
    else
      Sentry.capture_exception(exception_or_message, args)
    end
  end

  def self.is_configured?
    Sentry.get_current_client != nil
  end

  def self.configure
    raise GovukError::AlreadyInitialised if is_configured?

    Sentry.init do |sentry_config|
      config = Configuration.new(sentry_config)
      yield config if block_given?
    end
  end
end
