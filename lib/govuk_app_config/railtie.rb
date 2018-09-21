module GovukAppConfig
  class Railtie < Rails::Railtie

    initializer('govuk_app_config') do |app|
      GovukXRay.initialize(app) if Rails.env.production?
    end

    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end

    config.after_initialize do |app|
      GovukXRay.start app if Rails.env.production?
    end
  end
end
