require "sentry-ruby"
require "sentry-rails"
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/govuk_error/configuration"
require "govuk_app_config/version"

module GovukError
  def self.notify(exception_or_message, args = {})
    # Allow users to use `parameters` as a key like the Airbrake
    # client, allowing easy upgrades.
    args[:extra] ||= {}
    args[:extra].merge!(parameters: args.delete(:parameters))

    args[:tags] ||= {}
    args[:tags][:govuk_app_config_version] = GovukAppConfig::VERSION

    Sentry.capture_exception(exception_or_message, args)
  end

  def self.configure
    @configuration ||= Configuration.new(Sentry::Configuration.new)
    yield @configuration
  end

  def self.init
    Sentry.init do |config|
      # system configuration properties, required for Sentry to work
      config.dsn = @configuration.dsn.instance_variable_get(:@raw_value)
      config.background_worker_threads = @configuration.background_worker_threads
      config.transport.transport_class = @configuration.transport.transport_class

      # actual configuration - make sure this is in sync with govuk_error/configure.rb
      config.before_send = @configuration.before_send
      config.enabled_environments = @configuration.enabled_environments
      config.excluded_exceptions = @configuration.excluded_exceptions
      config.inspect_exception_causes_for_exclusion = @configuration.inspect_exception_causes_for_exclusion
    end
  end
end
