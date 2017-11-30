# Rails applications have 2 outputs types:
#
# 1) Structured logging statements like the ones we create with
# `Rails.logger.info` and Rails request logging, which we do with the logstasher
# gem. These logs are output in JSON and can be read easily by our logging
# stack.
#
# 2) The second are logs that are outputted when an exception occurs or `puts`
# is used directly. This is unstructured text. Often this logging is sent to
# STDOUT directly.
#
# We want to differentiate between the two types. To do this, we direct all log
# statements that would _normally_ go to STDOUT to STDERR. This frees up the "real
# stdout" for use by our loggers.
$real_stdout = $stdout.clone
$stdout.reopen($stderr)

require 'logstasher'

module GovukLogging
  def self.configure
    # Send Rails' logs to STDERR because they're not JSON formatted.
    Rails.logger = ActiveSupport::TaggedLogging.new(Logger.new($stderr))

    # Custom that will be added to the Rails request logs
    LogStasher.add_custom_fields do |fields|
      # Mirrors Nginx request logging, e.g GET /path/here HTTP/1.1
      fields[:request] = "#{request.request_method} #{request.fullpath} #{request.headers["SERVER_PROTOCOL"]}"

      # Pass request Id to logging
      fields[:govuk_request_id] = request.headers["GOVUK-Request-Id"]

      fields[:varnish_id] = request.headers["X-Varnish"]

      fields[:govuk_app_config] = GovukAppConfig::VERSION
    end

    Rails.application.config.logstasher.enabled = true

    # Log controller actions so that we can graph response times
    Rails.application.config.logstasher.controller_enabled = true

    # The other loggers are not that interesting in production
    Rails.application.config.logstasher.mailer_enabled = false
    Rails.application.config.logstasher.record_enabled = false
    Rails.application.config.logstasher.view_enabled = false
    Rails.application.config.logstasher.job_enabled = false

    Rails.application.config.logstasher.logger = Logger.new($real_stdout)
    Rails.application.config.logstasher.supress_app_log = true
  end
end
