require "delegate"
require "govuk_app_config/govuk_error/govuk_data_sync"

module GovukError
  class Configuration < SimpleDelegator
    attr_reader :data_sync
    attr_accessor :data_sync_excluded_exceptions

    def initialize(_sentry_configuration)
      super
      @data_sync = GovukDataSync.new(ENV["GOVUK_DATA_SYNC_PERIOD"])
      set_up_defaults
    end

    def set_up_defaults
      self.excluded_exceptions = [
        # Default ActionDispatch rescue responses
        "ActionController::RoutingError",
        "AbstractController::ActionNotFound",
        "ActionController::MethodNotAllowed",
        "ActionController::UnknownHttpMethod",
        "ActionController::NotImplemented",
        "ActionController::UnknownFormat",
        "Mime::Type::InvalidMimeType",
        "ActionController::MissingExactTemplate",
        "ActionController::InvalidAuthenticityToken",
        "ActionController::InvalidCrossOriginRequest",
        "ActionDispatch::Http::Parameters::ParseError",
        "ActionController::BadRequest",
        "ActionController::ParameterMissing",
        "Rack::QueryParser::ParameterTypeError",
        "Rack::QueryParser::InvalidParameterError",
        # Default ActiveRecord rescue responses
        "ActiveRecord::RecordNotFound",
        "ActiveRecord::StaleObjectError",
        "ActiveRecord::RecordInvalid",
        "ActiveRecord::RecordNotSaved",
        # Additional items
        "ActiveJob::DeserializationError",
        "CGI::Session::CookieStore::TamperedWithCookie",
        "GdsApi::HTTPIntermittentServerError",
        "GdsApi::TimedOutException",
        "GDS::SSO::PermissionDeniedError",
        "Mongoid::Errors::DocumentNotFound",
        "Puma::HttpParserError",
        "Sinatra::NotFound",
        "Slimmer::IntermittentRetrievalError",
        "Slimmer::SourceWrapperNotFoundError",
        "Sidekiq::JobRetry::Skip",
        "Sanitiser::Strategy::SanitisingError",
        "SignalException",
      ]

      # This will exclude exceptions that are triggered by one of the ignored
      # exceptions. For example, when any exception occurs in a template,
      # Rails will raise a ActionView::Template::Error, instead of the original error.
      self.inspect_exception_causes_for_exclusion = true

      # List of exceptions to ignore if they take place during the data sync.
      # Some errors are transient in nature, e.g. PostgreSQL databases being
      # unavailable, and add little value. In fact, their presence can greatly
      # increase the number of errors being sent and risk genuine errors being
      # rate-limited by Sentry.
      self.data_sync_excluded_exceptions = [
        "PG::Error",
        "GdsApi::ContentStore::ItemNotFound",
      ]

      # Avoid "Sending envelope with items ... to Sentry" logspew, since we
      # don't use Sentry's automatic session tracking.
      self.auto_session_tracking = false

      @before_send_callbacks = [
        ignore_excluded_exceptions_in_data_sync,
        increment_govuk_statsd_counters,
      ]
      # Need to invoke an arbitrary `before_send=` in order to trigger the
      # `before_send_callbacks` behaviour
      self.before_send = ->(error_or_event, _hint) { error_or_event }
    end

    def before_send=(closure)
      @before_send_callbacks.insert(-2, closure)
      super(run_before_send_callbacks)
    end

  protected

    def ignore_excluded_exceptions_in_data_sync
      ->(event, hint) {
        data_sync_ignored_error = data_sync_excluded_exceptions.any? do |exception_to_ignore|
          exception_to_ignore = Object.const_get(exception_to_ignore) unless exception_to_ignore.is_a?(Module)
          exception_chain = Sentry::Utils::ExceptionCauseChain.exception_to_array(hint[:exception])
          exception_chain.any? { |exception| exception.is_a?(exception_to_ignore) }
        rescue NameError
          # the exception type represented by the exception_to_ignore string
          # doesn't even exist in this environment, so won't be found in the chain
          false
        end

        event unless data_sync.in_progress? && data_sync_ignored_error
      }
    end

    def increment_govuk_statsd_counters
      ->(event, hint) {
        if hint[:exception]
          GovukStatsd.increment("errors_occurred")
          GovukStatsd.increment("error_types.#{hint[:exception].class.name.split('::').last.underscore}")
        end
        event
      }
    end

    def run_before_send_callbacks
      ->(event, hint) {
        result = event
        @before_send_callbacks.each do |callback|
          result = callback.call(event, hint)
          break if result.nil?
        end
        result
      }
    end
  end
end
