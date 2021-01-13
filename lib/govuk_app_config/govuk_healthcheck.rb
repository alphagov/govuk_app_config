require "govuk_app_config/govuk_healthcheck/checkup"
require "govuk_app_config/govuk_healthcheck/active_record"
require "govuk_app_config/govuk_healthcheck/mongoid"
require "govuk_app_config/govuk_healthcheck/rails_cache"
require "govuk_app_config/govuk_healthcheck/redis"
require "govuk_app_config/govuk_healthcheck/sidekiq_redis"
require "govuk_app_config/govuk_healthcheck/threshold_check"
require "govuk_app_config/govuk_healthcheck/sidekiq_queue_check"
require "govuk_app_config/govuk_healthcheck/sidekiq_queue_latency_check"
require "govuk_app_config/govuk_healthcheck/sidekiq_retry_size_check"
require "json"

module GovukHealthcheck
  def self.rack_response(*checks)
    proc do
      [
        200,
        { "Content-Type" => "application/json" },
        [JSON.dump(healthcheck(checks))],
      ]
    end
  end

  def self.healthcheck(checks)
    Checkup.new(checks).run
  end
end
