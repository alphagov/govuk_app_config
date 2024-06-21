module GovukTimezone
  def self.configure(config)
    case config.time_zone
    when "UTC"
      Rails.logger.info "govuk_app_config changing time_zone from UTC (the default) to London"
    when "London"
      Rails.logger.info "govuk_app_config always sets time_zone to London - there is no need to set config.time_zone in your app"
    else
      raise "govuk_app_config prevents configuring time_zones other than London - config.time_zone was set to #{config.time_zone}"
    end

    config.time_zone = "London"
  end
end
