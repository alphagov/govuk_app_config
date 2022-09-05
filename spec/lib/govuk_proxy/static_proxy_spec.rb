require "spec_helper"
require "govuk_app_config/govuk_proxy/static_proxy"
require "rack/mock"

RSpec.describe GovukProxy::StaticProxy do
  def test_request(path, proxied)
    dest_host = (proxied ? static_domain : app_domain)

    stub_request(:get, "https://#{dest_host}#{path}")
        .with(headers: { "Host" => dest_host })
        .to_return(status: 200, body: "", headers: {})

    env = Rack::MockRequest.env_for("http://#{app_domain}#{path}")
    status, _headers, _response = proxy.call(env)
    expect(status.to_i).to eq(200)
  end

  # dummy app to validate success
  let(:app) { ->(_env) { [200, {}, "success"] } }
  let(:app_domain) { "app.domain" }
  let(:static_domain) { "static.domain" }

  let(:proxy) { GovukProxy::StaticProxy.new(app, backend: "https://static.domain", streaming: false) }

  it "redirects the request if path begins with /asset/static" do
    test_request("/assets/static/a.css", true)
  end

  it "ignores requests not with path prefix /asset/static" do
    test_request("/assets/app/a.css", false)
  end

  it "ignores requests where /asset/static isn't a prefix" do
    test_request("/another/prefix/assets/static/a.css", false)
  end

  it "ignores requests with no path" do
    test_request("/", false)
  end
end
