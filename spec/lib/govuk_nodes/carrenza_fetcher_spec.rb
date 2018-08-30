require "spec_helper"

require "govuk_app_config/govuk_nodes/carrenza_fetcher"

RSpec.describe GovukNodes::CarrenzaFetcher do
  let(:response_code) { 200 }
  let(:response_body) {
    [
      puppet_instance("email_alert_api-1"),
      puppet_instance("email_alert_api-2"),
    ].to_json
  }

  let(:node_class) { "email-alert-api" }

  subject { described_class.new }

  before do
    stub_request(:get, db_url(node_class)).to_return(
      body: response_body,
      status: response_code,
    )
  end

  describe "#hostnames_of_class(node_class)" do
    it "queries puppetdb for the nodes" do
      subject.hostnames_of_class(node_class)

      expect(a_request(:get, db_url(node_class))).to have_been_made.once
    end

    it "allows underscores or hyphens" do
      subject.hostnames_of_class("email_alert_api")
      subject.hostnames_of_class("email-alert-api")

      expect(a_request(:get, db_url(node_class))).to have_been_made.twice
    end

    it "returns the names of the instances found" do
      expect(subject.hostnames_of_class(node_class)).to match_array(%w[
        email_alert_api-1
        email_alert_api-2
      ])
    end

    context "when the response is a 500" do
      let(:response_body) { "" }
      let(:response_code) { 500 }

      it "raises exceptions" do
        expect {
          subject.hostnames_of_class(node_class)
        }.to raise_error(OpenURI::HTTPError)
      end
    end

    context "when the response is a 400" do
      let(:response_body) { "" }
      let(:response_code) { 403 }

      it "raises an exception" do
        expect {
          subject.hostnames_of_class(node_class)
        }.to raise_error(OpenURI::HTTPError)
      end
    end

    context "when the response is a 300" do
      let(:response_body) { "" }
      let(:response_code) { 302 }

      it "raises an exception" do
        expect {
          subject.hostnames_of_class(node_class)
        }.to raise_error(OpenURI::HTTPError)
      end
    end
  end
end
