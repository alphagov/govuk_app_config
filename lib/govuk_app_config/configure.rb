if defined?(Airbrake)
  raise "This gem isn't compatible with Airbrake. Please remove it from the Gemfile."
end

Raven.configure do |config|
  # We need this until https://github.com/getsentry/raven-ruby/pull/736 is released
  config.current_environment = ENV["SENTRY_CURRENT_ENV"]

  config.should_capture = Proc.new do |error|
    capture_filters = GovukError.configuration.capture_filters
    capture_filters.empty? || capture_filters.all? { |filter| filter.call(error) }
  end

  config.transport_failure_callback = Proc.new {
    GovukStatsd.increment("error_reports_failed")
  }
end

# We're misusing the `should_capture` block here to hook into raven until
# there's a better way: https://github.com/getsentry/raven-ruby/pull/750
GovukError.configure do |error_config|
  error_config.add_capture_filter do
    GovukStatsd.increment("errors_occurred")

    # For backwards compatibility
    GovukStatsd.increment("errbit.errors_occurred")

    # Return true so that we don't accidentally skip the error
    true
  end
end
