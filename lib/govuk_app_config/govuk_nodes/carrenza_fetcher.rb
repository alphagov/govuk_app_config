require "open-uri"

class GovukNodes
  class CarrenzaFetcher
    def hostnames_of_class(node_class)
      instances_of_class(node_class).map do |instance|
        instance.fetch("name")
      end
    end

  private

    def instances_of_class(node_class)
      url = "#{puppetdb_node_url}?#{query_string(node_class)}"
      json_response = open(url).read
      JSON.parse(json_response)
    end

    def query_string(node_class)
      hyphenated_node_class = node_class.tr("_", "-")
      query = %{["or", ["~", ["fact", "fqdn"], "^#{hyphenated_node_class}-\\d+."]]}

      URI.encode_www_form(query: query)
    end

    def puppetdb_node_url
      @puppetdb_node_url ||= ENV["PUPPETDB_NODE_URL"]
    end
  end
end
