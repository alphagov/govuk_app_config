module GovukOpenTelemetry
  def self.should_configure?
    ENV["ENABLE_OPEN_TELEMETRY"] == "true"
  end

  def self.configure(service_name)
    return unless should_configure?

    require "opentelemetry/sdk"
    require "opentelemetry/exporter/otlp"
    require "opentelemetry/instrumentation/all"

    OpenTelemetry::SDK.configure do |config|
      config.service_name = service_name
      config.use_all # enables all instrumentation!
      config.logger = Logger.new(File::NULL) if in_rake_task?
    end
  end

  def self.in_rake_task?
    Rails.const_defined?(:Rake) && Rake.application.top_level_tasks.any?
  end
end
