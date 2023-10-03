require "prometheus_exporter"
require "prometheus_exporter/metric"
require "prometheus_exporter/server"
require "prometheus_exporter/middleware"

module GovukPrometheusExporter
  #
  # See https://github.com/discourse/prometheus_exporter/pull/293
  #
  # RailsMiddleware can be removed and replaced with the default middleware if
  # that PR is merged / released
  #
  class RailsMiddleware < PrometheusExporter::Middleware
    def default_labels(env, _result)
      controller_instance = env["action_controller.instance"]
      action = controller = nil
      if controller_instance
        action = controller_instance.action_name
        controller = controller_instance.controller_name
      elsif (cors = env["rack.cors"]) && cors.respond_to?(:preflight?) && cors.preflight?
        # if the Rack CORS Middleware identifies the request as a preflight request,
        # the stack doesn't get to the point where controllers/actions are defined
        action = "preflight"
        controller = "preflight"
      end
      {
        action: action || "other",
        controller: controller || "other",
      }
    end
  end

  class SinatraMiddleware < PrometheusExporter::Middleware
    def default_labels(_env, _result)
      # The default prometheus exporter middleware uses the controller and
      # action as labels.  These aren't meaningful in Sinatra applications, and
      # other options (such as request.path_info) have potentially very high
      # cardinality.  For now, just accept that we can't be more specific than
      # the application / pod and don't provide any other labels
      {}
    end
  end

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

  def self.configure(collectors: [], default_aggregation: PrometheusExporter::Metric::Histogram)
    return unless should_configure

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
        Rails.application.middleware.unshift RailsMiddleware, instrument: :prepend
      end

      if defined?(Sinatra)
        Sinatra.use SinatraMiddleware
      end
    rescue Errno::EADDRINUSE
      warn "Could not start Prometheus metrics server as address already in use."
    end
  end
end
