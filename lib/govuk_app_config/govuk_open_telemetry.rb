module GovukOpenTelemetry
  def self.should_configure?
    ENV["GOVUK_ENVIRONMENT"] == "integration"
  end

  def self.configure(service_name)
    return unless should_configure?

    require "opentelemetry/sdk"
    require "opentelemetry/exporter/otlp"
    require "opentelemetry/instrumentation/all"

    OpenTelemetry::SDK.configure do |config|
      config.service_name = service_name
      config.use_all # enables all instrumentation!
    end
  end
end
