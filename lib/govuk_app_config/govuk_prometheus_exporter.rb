require "prometheus_exporter/server"
require "prometheus_exporter/middleware"

module GovukPrometheusExporter
  def self.configure
    unless Rails.env == "test"
      server = PrometheusExporter::Server::WebServer.new bind: "localhost", port: 9394
      server.start

      Rails.application.middleware.unshift PrometheusExporter::Middleware
    end
  end
end
