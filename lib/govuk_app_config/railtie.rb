module GovukAppConfig
  class Railtie < Rails::Railtie
    initializer('govuk_app_config') do |app|
      GovukXRay.initialize(app) if Rails.env.production? && !ENV.has_key?("GOVUK_APP_CONFIG_DISABLE_XRAY")
    end

    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end

    config.after_initialize do
      GovukXRay.start if Rails.env.production? && !ENV.has_key?("GOVUK_APP_CONFIG_DISABLE_XRAY")
    end
  end
end
