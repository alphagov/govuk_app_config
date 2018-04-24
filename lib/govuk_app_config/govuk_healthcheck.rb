require "govuk_app_config/govuk_healthcheck/checkup"
require "govuk_app_config/govuk_healthcheck/active_record"
require "govuk_app_config/govuk_healthcheck/sidekiq_redis"
require "json"

module GovukHealthcheck
  def self.rack_response(*checks)
    proc { [200, {}, [JSON.dump(healthcheck(checks))]] }
  end

  def self.healthcheck(checks)
    Checkup.new(checks).as_json
  end
end
