module GovukError
  class CustomFingerprint
    def self.sample(event)
      # TODO - it's not clear if this is possible, given that Ruby SDK fingerprinting
      # has no documentation: https://docs.sentry.io/platforms/ruby/data-management/event-grouping/sdk-fingerprinting/
      # The implication is that it's not supported yet.
      ["fingerprint"]
    end
  end
end
