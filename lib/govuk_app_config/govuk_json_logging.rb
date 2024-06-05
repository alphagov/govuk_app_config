require "json"
require "logstasher"
require "action_controller"

module GovukJsonLogging
  class Configuration
    def initialize
      @custom_fields_block = proc {}
    end

    attr_reader :custom_fields_block

    def add_custom_fields(&block)
      @custom_fields_block = block if block_given?
    end
  end

  def self.configure(&block)
    # Fixes the monkey patch from the logstasher gem to support Rails 7
    config = Rails.application.config.logstasher
    if (!config.controller_monkey_patch && config.controller_monkey_patch != false) || config.controller_monkey_patch == true
      require_relative "./govuk_json_logging/rails_ext/action_controller/metal/instrumentation"
    end

    configuration = Configuration.new

    configuration.instance_eval(&block) if block_given?

    # We disable buffering, so that logs aren't lost on crash or delayed
    # indefinitely while troubleshooting.
    $stdout.sync = true

    Rails.logger = ActiveSupport::Logger.new($stdout, level: Rails.logger.level)
    Rails.logger.formatter = proc { |severity, datetime, _progname, msg|
      hash = {
        "@timestamp": datetime.utc.iso8601(3),
        message: msg,
        level: severity,
        tags: %w[rails],
      }

      if defined?(GdsApi::GovukHeaders) && !GdsApi::GovukHeaders.headers[:govuk_request_id].nil?
        hash[:govuk_request_id] = GdsApi::GovukHeaders.headers[:govuk_request_id]
      end

      "#{hash.to_json}\n"
    }

    LogStasher.add_custom_fields do |fields|
      # Mirrors Nginx request logging, e.g. GET /path/here HTTP/1.1
      fields[:request] = "#{request.request_method} #{request.fullpath} #{request.headers['SERVER_PROTOCOL']}"

      fields[:govuk_request_id] = request.headers["GOVUK-Request-Id"]
      fields[:varnish_id] = request.headers["X-Varnish"]
      fields[:govuk_app_config] = GovukAppConfig::VERSION

      instance_exec(fields, &configuration.custom_fields_block) if block_given?
    end

    Rails.application.config.logstasher.enabled = true

    # Log controller actions so that we can graph response times.
    Rails.application.config.logstasher.controller_enabled = true

    # The other loggers are not that interesting in production.
    Rails.application.config.logstasher.mailer_enabled = false
    Rails.application.config.logstasher.record_enabled = false
    Rails.application.config.logstasher.view_enabled = false
    Rails.application.config.logstasher.job_enabled = false

    # Elasticsearch index expect source to be an object and logstash defaults
    # source to be the host IP address causing logs to be dropped.
    Rails.application.config.logstasher.source = {}
    # Elasticsearch index expect error to be an object and logstash defaults
    # error to be a string causing logs to be dropped.
    Rails.application.config.logstasher.field_renaming = {
      error: :error_message,
    }

    Rails.application.config.logstasher.logger = Logger.new(
      $stdout,
      level: Rails.logger.level,
      formatter: proc { |_severity, _datetime, _progname, msg|
        "#{msg.is_a?(String) ? msg : msg.inspect}\n"
      },
    )
    Rails.application.config.logstasher.suppress_app_log = true

    if defined?(GdsApi::Base)
      GdsApi::Base.default_options ||= {}

      # The gds-api-adapters gem logs JSON to describe the requests it makes and
      # the responses it gets, so direct this to the logstasher logger.
      GdsApi::Base.default_options[:logger] = Rails.application.config.logstasher.logger
    end
  end
end
