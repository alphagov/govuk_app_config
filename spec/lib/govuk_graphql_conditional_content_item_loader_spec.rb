require "spec_helper"
require "govuk_app_config/govuk_graphql_conditional_content_item_loader"
require "ostruct"
require "rails"

RSpec.describe GovukGraphql::ConditionalContentItemLoader do
  let(:base_path) { "/foo" }
  let(:request) { double("request", path: base_path, params: {}, env: {}) }
  let(:content_store_client) { double("content_store_client") }
  let(:publishing_api_client) { double("publishing_api_client") }
  let(:loader) do
    described_class.new(
      request: request,
      content_store_client: content_store_client,
      publishing_api_client: publishing_api_client,
    )
  end

  before do
    config = OpenStruct.new(
      graphql_allowed_schemas: %w[test_schema],
      graphql_traffic_rates: { "test_schema" => 1.0 },
    )
    stub_const("GdsApi::HTTPErrorResponse", Class.new(StandardError) do
      attr_reader :code

      def initialize(code)
        @code = code
        super("HTTP #{code}")
      end
    end)
    stub_const("GdsApi::TimedOutException", Class.new(StandardError))
    allow(Rails).to receive(:application).and_return(double(config: config))
  end

  describe "#load" do
    context "when can load from GraphQL" do
      before do
        allow(loader).to receive(:can_load_from_graphql?).and_return(true)
        allow(publishing_api_client).to receive(:graphql_live_content_item).with(base_path).and_return("graphql_item")
      end

      it "returns content item from GraphQL/Publishing API" do
        expect(loader.load).to eq("graphql_item")
      end

      it "sets Prometheus labels" do
        loader.load

        expect(request.env["govuk.prometheus_labels"]["graphql_status_code"]).to eq(200)
      end

      it "sets Prometheus labels and raises error for GdsApi::HTTPErrorResponse" do
        error = GdsApi::HTTPErrorResponse.new(503)
        allow(publishing_api_client).to receive(:graphql_live_content_item).and_raise(error)

        expect { loader.load }.to raise_error(GdsApi::HTTPErrorResponse)
        expect(request.env["govuk.prometheus_labels"]["graphql_status_code"]).to eq(503)
      end

      it "sets Prometheus labels and raises error for GdsApi::TimedOutException" do
        error = GdsApi::TimedOutException.new
        allow(publishing_api_client).to receive(:graphql_live_content_item).and_raise(error)

        expect { loader.load }.to raise_error(GdsApi::TimedOutException)
        expect(request.env["govuk.prometheus_labels"]["graphql_api_timeout"]).to eq(true)
      end
    end

    context "when can't load from GraphQL" do
      before do
        allow(loader).to receive(:can_load_from_graphql?).and_return(false)
        allow(content_store_client).to receive(:content_item).with(base_path).and_return("item_from_cs")
      end

      it "returns content item from Content Store" do
        expect(loader.load).to eq("item_from_cs")
      end

      it "calls Content Store once" do
        expect(content_store_client).to receive(:content_item).with(base_path)
          .once

        loader.load
      end
    end
  end

  describe "#can_load_from_graphql?" do
    it "returns false if request is nil" do
      loader = described_class.new(
        request: nil,
        content_store_client: double("content_store_client"),
        publishing_api_client: double("publishing_api_client"),
      )

      expect(loader.can_load_from_graphql?).to be false
    end

    it "returns false for draft host" do
      stub_const("ENV", ENV.to_hash.merge("PLEK_HOSTNAME_PREFIX" => "draft-"))

      expect(loader.can_load_from_graphql?).to be false
    end

    it "returns true if request params graphql is 'true'" do
      allow(request).to receive(:params).and_return("graphql" => "true")

      expect(loader.can_load_from_graphql?).to be true
    end

    it "returns false if request params graphql is 'false'" do
      allow(request).to receive(:params).and_return("graphql" => "false")

      expect(loader.can_load_from_graphql?).to be false
    end

    it "returns false if schema_name is not in allowed schemas" do
      allow(loader).to receive(:content_item_from_content_store)
        .and_return("schema_name" => "not_allowed")

      expect(loader.can_load_from_graphql?).to be false
    end

    it "returns true if schema_name is allowed and random < rate" do
      allow(loader).to receive(:content_item_from_content_store)
        .and_return("schema_name" => "test_schema")
      allow(Random).to receive(:rand).and_return(0.5)

      expect(loader.can_load_from_graphql?).to be true
    end
  end
end
