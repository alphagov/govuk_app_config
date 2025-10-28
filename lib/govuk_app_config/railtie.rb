require "plek"

# Workaround for Logstasher initializer conflict under Rails 8.1
begin
  require "logstasher/railtie"

  if defined?(LogStasher::Railtie)
    # Remove duplicate initializers that cause cyclic dependency
    LogStasher::Railtie.initializers.delete_if { |i| i.name == :logstasher }

    # Replace with a single clean initializer
    LogStasher::Railtie.initializer(:logstasher_fixed, after: :load_config_initializers) {}
  end
rescue LoadError, NameError
  # Skip if Logstasher not present
end

module GovukAppConfig
  class Railtie < Rails::Railtie
    initializer "govuk_app_config.configure_govuk_proxy" do |app|
      if ENV["GOVUK_PROXY_STATIC_ENABLED"] == "true"
        app.middleware.use GovukProxy::StaticProxy, backend: Plek.find("static")
      end
    end

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
