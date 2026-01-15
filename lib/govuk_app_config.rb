require "govuk_app_config/govuk_error"
require "govuk_app_config/govuk_healthcheck"
require "govuk_app_config/govuk_open_telemetry"
require "govuk_app_config/govuk_prometheus_exporter"
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/version"

if defined?(Rails)
  require "govuk_app_config/govuk_content_security_policy"
  require "govuk_app_config/govuk_environment"
  require "govuk_app_config/govuk_i18n"
  require "govuk_app_config/govuk_json_logging"
  require "govuk_app_config/govuk_timezone"
  require "govuk_app_config/railtie"
end
