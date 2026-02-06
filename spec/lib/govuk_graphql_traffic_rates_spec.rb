require "spec_helper"
require "govuk_app_config/govuk_graphql_traffic_rates"

RSpec.describe GovukGraphqlTrafficRates do
  let(:config) { OpenStruct.new }

  before do
    allow(Rails).to receive(:application).and_return(double(config: config))
  end

  describe ".configure" do
    it "does not set graphql config values, if GraphQL rates are not configured" do
      ClimateControl.modify({}) do
        described_class.configure

        expect(config.graphql_traffic_rates).to be_nil
        expect(config.graphql_allowed_schemas).to be_nil
      end
    end

    it "sets graphql_traffic_rates and graphql_allowed_schemas if GraphQL rates are defined" do
      ClimateControl.modify(
        GRAPHQL_RATE_ANSWER: "0.1",
        GRAPHQL_RATE_CALENDAR: "0.5",
      ) do
        described_class.configure

        expect(Rails.application.config.graphql_traffic_rates).to eq(
          "answer" => 0.1,
          "calendar" => 0.5,
        )

        expect(Rails.application.config.graphql_allowed_schemas)
          .to match_array(%w[answer calendar])
      end
    end
  end

  describe ".graphql_rates_from_env" do
    it "returns an empty hash when no GRAPHQL_RATE env vars are set" do
      ClimateControl.modify({}) do
        expect(described_class.graphql_rates_from_env).to eq({})
      end
    end

    it "extracts graphql rates from environment variables" do
      ClimateControl.modify(
        GRAPHQL_RATE_ANSWER: "0.1",
        GRAPHQL_RATE_CALENDAR: "0.5",
      ) do
        expect(described_class.graphql_rates_from_env).to eq(
          "answer" => 0.1,
          "calendar" => 0.5,
        )
      end
    end

    it "ignores non-GRAPHQL_RATE env vars" do
      ClimateControl.modify(
        GRAPHQL_RATE_ANSWER: "1.0",
        SOME_OTHER_VAR: "100",
      ) do
        expect(described_class.graphql_rates_from_env).to eq(
          "answer" => 1.0,
        )
      end
    end
  end
end
