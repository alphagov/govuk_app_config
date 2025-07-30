module GovukEnvironment
  def self.current
    ENV["GOVUK_ENVIRONMENT"] || "development"
  end
end
