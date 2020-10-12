GovukError.configure do |config|
  config.current_environment = ENV["SENTRY_CURRENT_ENV"]

  config.before_send = proc { |e|
    GovukStatsd.increment("errors_occurred")
    GovukStatsd.increment("error_types.#{e.class.name.demodulize.underscore}")
    e
  }

  config.silence_ready = !Rails.env.production? if defined?(Rails)

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

  # List of exceptions to ignore if they take place during the data sync.
  # Some errors are transient in nature, e.g. PostgreSQL databases being
  # unavailable, and add little value. In fact, their presence can greatly
  # increase the number of errors being sent and risk genuine errors being
  # rate-limited by Sentry.
  config.data_sync_excluded_exceptions = [
    "PG::Error",
  ]

  config.transport_failure_callback = proc {
    GovukStatsd.increment("error_reports_failed")
  }
end
