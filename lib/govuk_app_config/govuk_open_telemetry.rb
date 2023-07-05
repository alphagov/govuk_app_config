module GovukOpenTelemetry
  def self.should_configure?
    ENV["ENABLE_OPEN_TELEMETRY"] == "true"
  end

  def self.configure(service_name)
    return unless should_configure?

    require "opentelemetry/sdk"
    require "opentelemetry/exporter/otlp"
    require "opentelemetry/instrumentation/all"

    require "sentry-opentelemetry"

    OpenTelemetry::SDK.configure do |config|
      config.service_name = service_name
      config.use_all # enables all instrumentation!

      config.add_span_processor(Sentry::OpenTelemetry::SpanProcessor.instance)
    end

    OpenTelemetry.propagation = Sentry::OpenTelemetry::Propagator.new
  end
end
