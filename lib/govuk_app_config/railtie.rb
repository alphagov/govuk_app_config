require "plek"

module GovukAppConfig
  class Railtie < Rails::Railtie
    initializer "govuk_app_config.configure_govuk_proxy" do |app|
      if ENV["GOVUK_PROXY_STATIC_ENABLED"] == "true"
        app.middleware.use GovukProxy::StaticProxy, backend: Plek.find("static")
      end
    end

    initializer "govuk_app_config.configure_open_telemetry" do |app|
      GovukOpenTelemetry.configure(app.class.module_parent_name.underscore)
    end

    config.before_initialize do
      GovukJsonLogging.configure if ENV["GOVUK_RAILS_JSON_LOGGING"]
    end

    config.after_initialize do
      GovukError.configure unless GovukError.is_configured?
    end
  end
end
