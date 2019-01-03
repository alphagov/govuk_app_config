module GovukAppConfig
  class Railtie < Rails::Railtie
    initializer('govuk_app_config') do |app|
      GovukXRay.initialize(app) if enable_railtie_for?('xray')
    end

    config.before_initialize do
      GovukLogging.configure if enable_railtie_for?('logging')
    end

    config.after_initialize do
      GovukXRay.start if enable_railtie_for?('xray')
    end

    def self.enable_railtie_for?(name)
      Rails.env.production? && !ENV.has_key?("GOVUK_APP_CONFIG_DISABLE_#{name.upcase}_RAILTIE")
    end
  end
end
