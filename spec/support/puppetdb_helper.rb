require "uri"

module PuppetDBHelper
  # Source: https://puppet.com/docs/puppetdb/2.3/api/query/v2/nodes.html
  def puppet_instance(name)
    {
      name: name,
      deactivated: nil,
      catalog_timestamp: Time.now.iso8601,
      facts_timestamp: Time.now.iso8601,
      report_timestamp: Time.now.iso8601,
    }
  end

  def db_url(base_url, node_class)
    query = '["or", ["~", ["fact", "fqdn"], "^' + node_class + '-\d+."]]'
    query_string = URI.encode_www_form(query: query)
    "#{base_url}?#{query_string}"
  end
end

RSpec.configure do |c|
  c.include PuppetDBHelper
end
