module GovukAppConfig
  class Railtie < Rails::Railtie
    config.before_initialize do
      GovukLogging.configure if Rails.env.production?
    end

    # Avoid relying on dodgy HTTP headers about the requester's IP:
    # https://blog.gingerlime.com/2012/rails-ip-spoofing-vulnerabilities-and-protection/
    #
    # Protection of GOV.UK should be implemented at the network level:
    # https://github.com/alphagov/govuk-cdn-config/blob/2c8b87fd6d1bef7067ea872f7232c53effbf31b4/vcl_templates/www.vcl.erb#L203
    initializer "govuk_app_config.remove_remote_ip" do |app|
      app.middleware.delete ActionDispatch::RemoteIp
    end
  end
end
