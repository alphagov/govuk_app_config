require "plek"

# Workaround for Logstasher initializer conflict under Rails 8.1
begin
  require "logstasher/railtie"

  # Only apply this workaround for Rails 8.1+ where the boot cycle issue exists.
  # This prevents any potential regressions for apps on older Rails versions.
  if defined?(LogStasher::Railtie) && Gem::Version.new(Rails::VERSION::STRING) >= Gem::Version.new("8.1")
    # Remove duplicate initializers that cause cyclic dependency
    LogStasher::Railtie.initializers.delete_if { |i| i.name == :logstasher }

    # Replace with a single clean initializer that actually sets up LogStasher
    LogStasher::Railtie.initializer(:logstasher_govuk_fix, after: :load_config_initializers) do |app|
      LogStasher.setup(app) if app.config.logstasher.enabled
    end
  end
rescue LoadError, NameError
  # Skip if Logstasher not present
end

module GovukAppConfig
  class Railtie < Rails::Railtie
    initializer "govuk_app_config.configure_open_telemetry" do |app|
      unless Rails.const_defined?(:Console)
        GovukOpenTelemetry.configure(app.class.module_parent_name.underscore)
      end
    end

    initializer "govuk_app_config.configure_timezone", before: "active_support.initialize_time_zone" do |app|
      GovukTimezone.configure(app.config)
    end

    config.before_initialize do
      GovukJsonLogging.configure if ENV["GOVUK_RAILS_JSON_LOGGING"]
    end

    config.after_initialize do
      GovukError.configure unless GovukError.is_configured?
    end
  end
end
