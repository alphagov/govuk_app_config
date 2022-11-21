require "plek"

module GovukAppConfig
  class Railtie < Rails::Railtie
    initializer "govuk_app_config.configure_govuk_proxy" do |app|
      if ENV["GOVUK_PROXY_STATIC_ENABLED"] == "true"
        app.middleware.use GovukProxy::StaticProxy, backend: Plek.find("static")
      end
    end

    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end

    config.after_initialize do
      GovukError.configure unless GovukError.is_configured?
    end
  end
end
