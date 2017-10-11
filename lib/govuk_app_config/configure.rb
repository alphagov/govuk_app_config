if defined?(Airbrake)
  raise "This gem isn't compatible with Airbrake. Please remove it from the Gemfile."
end

GovukError.configure do |config|
  # We're misusing the `should_capture` block here to hook into raven until
  # there's a better way: https://github.com/getsentry/raven-ruby/pull/750
  config.should_capture = Proc.new {
    GovukStatsd.increment("errors_occurred")

    # For backwards compatibility
    GovukStatsd.increment("errbit.errors_occurred")

    # Return true so that we don't accidentally skip the error
    true
  }

  config.transport_failure_callback = Proc.new {
    GovukStatsd.increment("error_reports_failed")
  }
end
