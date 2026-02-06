module GovukGraphql
  class ConditionalContentItemLoader
    attr_reader :content_store_client, :publishing_api_client, :request, :base_path

    def initialize(request:, content_store_client: GdsApi.content_store, publishing_api_client: GdsApi.publishing_api)
      @content_store_client = content_store_client
      @publishing_api_client = publishing_api_client
      @request = request
      @base_path = request&.path
    end

    def load
      can_load_from_graphql? ? content_item_from_graphql : content_item_from_content_store
    end

    def can_load_from_graphql?
      return false unless request

      return false if draft_host?

      return force_graphql_param unless force_graphql_param.nil?

      schema_name = content_item_from_content_store["schema_name"]
      return false unless graphql_schema_allowed?(schema_name)

      within_graphql_traffic_rate?(schema_name)
    end

  private

    def content_item_from_graphql
      set_prometheus_labels
      publishing_api_client.graphql_live_content_item(base_path)
    rescue GdsApi::HTTPErrorResponse => e
      set_prometheus_labels(graphql_status_code: e.code)
      raise e
    rescue GdsApi::TimedOutException => e
      set_prometheus_labels(graphql_api_timeout: true)
      raise e
    end

    def content_item_from_content_store
      @content_item_from_content_store ||= content_store_client.content_item(base_path)
    end

    def set_prometheus_labels(graphql_status_code: 200, graphql_api_timeout: false)
      prometheus_labels = request.env.fetch("govuk.prometheus_labels", {})

      hash = {
        "graphql_status_code" => graphql_status_code,
        "graphql_api_timeout" => graphql_api_timeout,
      }

      request.env["govuk.prometheus_labels"] = prometheus_labels.merge(hash)
    end

    def draft_host?
      ENV["PLEK_HOSTNAME_PREFIX"] == "draft-"
    end

    def force_graphql_param
      return true if request.params["graphql"] == "true"

      false if request.params["graphql"] == "false"
    end

    def graphql_schema_allowed?(schema_name)
      Rails.application.config.graphql_allowed_schemas.include?(schema_name)
    end

    def within_graphql_traffic_rate?(schema_name)
      graphql_traffic_rate = Rails.application.config.graphql_traffic_rates.fetch(schema_name)
      Random.rand(1.0) < graphql_traffic_rate
    end
  end
end
