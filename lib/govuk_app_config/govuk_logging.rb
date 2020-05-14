require 'logstasher'
require 'action_controller'
require_relative 'rails_ext/action_dispatch/debug_exceptions'

module GovukLogging
  def self.configure
    # GOV.UK Rails applications are expected to output JSON to stdout which is
    # then indexed in a Kibana instance. These log outputs are created by the
    # logstasher gem.
    #
    # Rails applications will typically write other things to stdout such as
    # `Rails.logger` calls or 'puts' statements. However these are not in a
    # JSON format which causes problems for the log file parsers.
    #
    # To resolve this we've directed stdout to stderr, to cover any Rails
    # writing. This frees up the normal stdout for the logstasher logs.
    $real_stdout = $stdout.clone
    $stdout.reopen($stderr)

    # Send Rails' logs to STDERR because they're not JSON formatted.
    Rails.logger = ActiveSupport::TaggedLogging.new(Logger.new($stderr, level: Rails.logger.level))

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

    Rails.application.config.logstasher.logger = Logger.new(
      $real_stdout,
      level: Rails.logger.level,
      formatter: proc { |_severity, _datetime, _progname, msg|
        "#{String === msg ? msg : msg.inspect}\n"
      }
    )
    Rails.application.config.logstasher.suppress_app_log = true

    if defined?(GdsApi::Base)
      GdsApi::Base.default_options ||= {}

      # The GDS API Adapters gem logs JSON to describe the requests it
      # makes and the responses it gets, so direct this to the
      # logstasher logger
      GdsApi::Base.default_options[:logger] =
        Rails.application.config.logstasher.logger
    end

    RailsExt::ActionDispatch.monkey_patch_log_error if RailsExt::ActionDispatch.should_monkey_patch_log_error
  end
end
