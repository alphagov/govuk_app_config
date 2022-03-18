module GovukPrometheusExporter
  def self.configure
    unless Rails.env == "test"
      require "prometheus_exporter"
      require "prometheus_exporter/server"
      require "prometheus_exporter/middleware"

      server = PrometheusExporter::Server::WebServer.new bind: "0.0.0.0", port: 9394
      server.start

      Rails.application.middleware.unshift PrometheusExporter::Middleware
    end
  end
end
