if defined?(Airbrake)
  raise "This gem isn't compatible with Airbrake. Please remove it from the Gemfile."
end

GovukError.configure do |config|
  config.before_send = Proc.new { |e|
    GovukStatsd.increment("errors_occurred")

    # For backwards compatibility
    GovukStatsd.increment("errbit.errors_occurred")
  }

  config.should_capture = Proc.new { |e|
    exception_class = e.respond_to?(:original_exception) ? e.original_exception.class : e.class
    if exception_class.ancestors.any? { |c| c.name =~ /^GdsApi::(HTTPIntermittent|TimedOutException)/ }
      GovukStatsd.increment("gds_api_adapters.errors.#{e.class.name.demodulize.underscore}")
      false
    else
      true
    end
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
    'Mongoid::Errors::DocumentNotFound',
    'Sinatra::NotFound',
  ]

  config.transport_failure_callback = Proc.new {
    GovukStatsd.increment("error_reports_failed")
  }
end
