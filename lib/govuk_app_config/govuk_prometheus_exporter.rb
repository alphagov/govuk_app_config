module GovukPrometheusExporter
  def self.should_configure
    ENV["GOVUK_PROMETHEUS_EXPORTER"] == "true" && !(defined?(Rails) && Rails.env == "test")
  end

  def self.configure
    return unless should_configure

    require "prometheus_exporter"
    require "prometheus_exporter/server"
    require "prometheus_exporter/middleware"

    if defined?(Sidekiq)
      Sidekiq.configure_server do |config|
        require "prometheus_exporter/instrumentation"
        config.server_middleware do |chain|
          chain.add PrometheusExporter::Instrumentation::Sidekiq
        end
        config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
        config.on :startup do
          PrometheusExporter::Instrumentation::Process.start(type: "sidekiq")
          PrometheusExporter::Instrumentation::SidekiqProcess.start
          PrometheusExporter::Instrumentation::SidekiqQueue.start
          PrometheusExporter::Instrumentation::SidekiqStats.start
        end
      end
    end

    server = PrometheusExporter::Server::WebServer.new bind: "0.0.0.0", port: 9394
    server.start

    if defined?(Rails)
      Rails.application.middleware.unshift PrometheusExporter::Middleware
    end
  end
end
