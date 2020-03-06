GovukError.configure do |config|
  config.before_send = Proc.new { |e|
    GovukStatsd.increment("errors_occurred")
    GovukStatsd.increment("error_types.#{e.class.name.demodulize.underscore}")
    e
  }

  config.silence_ready = !Rails.env.production? if defined?(Rails)

  config.excluded_exceptions = [
    'AbstractController::ActionNotFound',
    'ActionController::BadRequest',
    'ActionController::InvalidAuthenticityToken',
    'ActionController::ParameterMissing',
    'ActionController::RoutingError',
    'ActionController::UnknownAction',
    'ActionController::UnknownHttpMethod',
    'ActionDispatch::RemoteIp::IpSpoofAttackError',
    'ActiveJob::DeserializationError',
    'ActiveRecord::RecordNotFound',
    'CGI::Session::CookieStore::TamperedWithCookie',
    'GdsApi::HTTPIntermittentServerError',
    'GdsApi::TimedOutException',
    'Mime::Type::InvalidMimeType',
    'Mongoid::Errors::DocumentNotFound',
    'Sinatra::NotFound',
  ]

  # This will exclude exceptions that are triggered by one of the ignored
  # exceptions. For example, when any exception occurs in a template,
  # Rails will raise a ActionView::Template::Error, instead of the original error.
  config.inspect_exception_causes_for_exclusion = true

  config.transport_failure_callback = Proc.new {
    GovukStatsd.increment("error_reports_failed")
  }
end
