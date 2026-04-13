require "plek"

# Workaround for Logstasher initializer conflict under Rails 8.1
begin
  require "logstasher/railtie"

  # Only apply this workaround for Rails 8.1+ where the boot cycle issue exists.
  # This prevents any potential regressions for apps on older Rails versions.
  if defined?(LogStasher::Railtie) && Gem::Version.new(Rails::VERSION::STRING) >= Gem::Version.new("8.1")
    # Remove the default initializer to fix a cyclic dependency boot crash on Rails 8.1.
    # LogStasher.setup is instead called explicitly in GovukJsonLogging.configure (after_initialize),
    # once logstasher.enabled has been set to true.
    LogStasher::Railtie.initializers.delete_if { |i| i.name == :logstasher }
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

    config.after_initialize do
      GovukJsonLogging.configure if ENV["GOVUK_RAILS_JSON_LOGGING"]
      GovukError.configure unless GovukError.is_configured?
    end
  end
end
