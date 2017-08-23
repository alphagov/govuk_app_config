require "statsd"

module GOVUK
  module Statsd
    def self.increment(*args)
      client.increment(*args)
    end

    def self.client
      @statsd_client ||= begin
        statsd_client = ::Statsd.new("localhost")
        statsd_client.namespace = ENV["GOVUK_STATSD_PREFIX"].to_s
        statsd_client
      end
    end
  end
end
