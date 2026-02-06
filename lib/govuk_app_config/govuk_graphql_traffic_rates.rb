module GovukGraphqlTrafficRates
  def self.configure
    rates = graphql_rates_from_env
    return if rates.empty?

    Rails.application.config.graphql_traffic_rates = rates
    Rails.application.config.graphql_allowed_schemas = rates.keys
  end

  def self.graphql_rates_from_env
    ENV
      .select { |key, _| key.start_with?("GRAPHQL_RATE_") }
      .transform_keys { |key| key.delete_prefix("GRAPHQL_RATE_").downcase }
      .transform_values(&:to_f)
  end
end
