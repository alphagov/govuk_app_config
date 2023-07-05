require "govuk_app_config/version"
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/govuk_error"
require "govuk_app_config/govuk_proxy/static_proxy"
require "govuk_app_config/govuk_healthcheck"
require "govuk_app_config/govuk_open_telemetry"
require "govuk_app_config/govuk_prometheus_exporter"

if defined?(Rails)
  require "govuk_app_config/govuk_json_logging"
  require "govuk_app_config/govuk_content_security_policy"
  require "govuk_app_config/railtie"
end
