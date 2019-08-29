module GovukAppConfig
  class Railtie < Rails::Railtie
    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end
  end
end
