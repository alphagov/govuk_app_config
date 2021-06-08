GovukError.configure do |config|
  # These are the environments (described by the `SENTRY_CURRENT_ENV`
  # ENV variable) where we want to capture Sentry errors. If
  # `SENTRY_CURRENT_ENV` isn't in this list, or isn't defined, then
  # don't capture the error.
  config.enabled_environments = %w[
    integration-blue-aws
    staging
    production
  ]

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
    "Slimmer::IntermittentRetrievalError",
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
    "GdsApi::ContentStore::ItemNotFound",
  ]

  config.before_send = lambda { |error_or_event, _hint|
    error_or_event
  }
end
