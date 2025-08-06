require "govuk_app_config/govuk_healthcheck/checkup"
require "govuk_app_config/govuk_healthcheck/active_record"
require "govuk_app_config/govuk_healthcheck/emergency_banner_redis"
require "govuk_app_config/govuk_healthcheck/mongoid"
require "govuk_app_config/govuk_healthcheck/rails_cache"
require "govuk_app_config/govuk_healthcheck/redis"
require "govuk_app_config/govuk_healthcheck/sidekiq_redis"
require "json"

module GovukHealthcheck
  def self.rack_response(*checks)
    proc do
      checkup = healthcheck(checks)
      [
        checkup[:status] == :ok ? 200 : 500,
        { "Content-Type" => "application/json" },
        [JSON.dump(checkup)],
      ]
    end
  end

  def self.healthcheck(checks)
    Checkup.new(checks).run
  end
end
