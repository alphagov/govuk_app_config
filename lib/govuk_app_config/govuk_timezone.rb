module GovukTimezone
  def self.configure(config)
    raise "govuk_app_config prevents configuring time_zone with config.time_zone - use config.govuk_time_zone instead" unless config.time_zone == "UTC"

    if config.respond_to? :govuk_time_zone
      config.time_zone = config.govuk_time_zone
    else
      Rails.logger.info 'govuk_app_config changing time_zone from UTC (the rails default) to London (the GOV.UK default). Set config.govuk_time_zone = "UTC" if you need UTC.'
      config.time_zone = "London"
    end
  end
end
