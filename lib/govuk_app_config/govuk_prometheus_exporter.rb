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

  def self.configure(collectors: [], default_aggregation: Prometheus::Metric::Histogram)
    return unless should_configure

    require "prometheus_exporter"
    require "prometheus_exporter/server"
    require "prometheus_exporter/middleware"

    # PrometheusExporter::Metric::Histogram.DEFAULT_BUCKETS tops out at 10 but
    # we have a few controller actions which are slower than this, so we add a
    # few extra buckets for slower requests
    PrometheusExporter::Metric::Histogram.default_buckets = [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 15, 25, 50].freeze
    PrometheusExporter::Metric::Base.default_aggregation = default_aggregation

    if defined?(Sidekiq)
      Sidekiq.configure_server do |config|
        require "sidekiq/api"
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

      collectors.each { |collector| server.collector.register_collector(collector.new) }

      server.start

      if defined?(Rails)
        Rails.application.middleware.unshift PrometheusExporter::Middleware, instrument: :prepend
      end

      if defined?(Sinatra)
        Sinatra.use PrometheusExporter::Middleware
      end
    rescue Errno::EADDRINUSE
      warn "Could not start Prometheus metrics server as address already in use."
    end
  end
end
