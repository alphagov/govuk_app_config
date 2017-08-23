require "sentry-raven"
require "govuk_config/statsd"

module GOVUK
  module Error
    def self.notify(exception_or_message, args = {})
      # Allow users to use `parameters` as a key like the Airbrake
      # client, allowing easy upgrades.
      args[:extra] ||= {}
      args[:extra].merge!(parameters: args.delete(:parameters))

      Raven.capture_exception(exception_or_message, args)
    end
  end
end
