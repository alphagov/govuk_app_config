module GovukAppConfig
  class Railtie < Rails::Railtie
    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end

    if Rails.env.development? && config.respond_to?(:hosts)
      config.hosts << "#{File.basename(Rails.root)}.dev.gov.uk"
    end
  end
end
