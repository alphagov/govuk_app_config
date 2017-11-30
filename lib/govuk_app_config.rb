require "govuk_app_config/version"
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/govuk_error"
require "govuk_app_config/govuk_logging"
require "govuk_app_config/configure"
require "govuk_app_config/railtie" if defined?(Rails)
