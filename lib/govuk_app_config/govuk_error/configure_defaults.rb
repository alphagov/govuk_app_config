module GovukError
  class ConfigureDefaults < SimpleDelegator
    def initialize(config)
      super

      config.current_environment = ENV["SENTRY_CURRENT_ENV"]

      config.before_send = proc { |e|
        GovukStatsd.increment("errors_occurred")
        GovukStatsd.increment("error_types.#{e.class.name.demodulize.underscore}")
        e
      }

      config.silence_ready = !Rails.env.production? if Object.const_defined?("Rails")

      config.excluded_exceptions = [
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
        "Mongoid::Errors::DocumentNotFound",
        "Sinatra::NotFound",
      ]

      # This will exclude exceptions that are triggered by one of the ignored
      # exceptions. For example, when any exception occurs in a template,
      # Rails will raise a ActionView::Template::Error, instead of the original error.
      config.inspect_exception_causes_for_exclusion = true

      config.transport_failure_callback = proc {
        GovukStatsd.increment("error_reports_failed")
      }

      config.should_capture = lambda do |error_or_event|
        exception_chain = Raven::Utils::ExceptionCauseChain.exception_to_array(error_or_event)
        data_sync_ignored_error = exception_chain.any? { |exception| exception.class.to_s == "PG::Error" }
        data_sync_time = Time.now.hour >= 22 || Time.now.hour < 8

        !(data_sync_ignored_error && data_sync_time)
      end
    end
  end
end
