require "plek"

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
