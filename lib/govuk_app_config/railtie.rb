module GovukAppConfig
  class Railtie < Rails::Railtie
    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end

    config.after_initialize do
      GovukError.configure unless GovukError.is_configured?
    end
  end
end
