module GovukPrometheusExporter
  def self.should_configure
    # Allow us to force the Prometheus Exporter for persistent Rake tasks...
    if ENV["GOVUK_PROMETHEUS_EXPORTER"] == "force"
      true
    elsif File.basename($PROGRAM_NAME) == "rake" ||
        defined?(Rails) && (Rails.const_defined?("Console") || Rails.env == "test")
      false
    else
      ENV["GOVUK_PROMETHEUS_EXPORTER"] == "true"
    end
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

    begin
      server = PrometheusExporter::Server::WebServer.new bind: "0.0.0.0", port: 9394
      server.start

      if defined?(Rails)
        Rails.application.middleware.unshift PrometheusExporter::Middleware
      end

      if defined?(Sinatra)
        Sinatra.use PrometheusExporter::Middleware
      end
    rescue Errno::EADDRINUSE
      warn "Warning: Could not connect to Prometheus Server"
    end
  end
end
