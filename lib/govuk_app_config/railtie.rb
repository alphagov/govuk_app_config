module GovukAppConfig
  class Railtie < Rails::Railtie
    def self.enable_railtie_for?(name)
      Rails.env.production? && !ENV.has_key?("GOVUK_APP_CONFIG_DISABLE_#{name.upcase}")
    end

    initializer('govuk_app_config') do |app|
      GovukXRay.initialize(app) if self.enable_railtie_for?('xray')
    end

    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end

    config.after_initialize do
      GovukXRay.start if self.enable_railtie_for?('xray')
    end
  end
end
