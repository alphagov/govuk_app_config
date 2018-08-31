require "spec_helper"

require "govuk_app_config/govuk_nodes"

RSpec.describe GovukNodes do
  let(:node_class) { "email_alert_api" }

  before do
    described_class.is_aws = aws_flag
  end

  after do
    described_class.is_aws = nil
  end


  context "if the AWS flag is not configured" do
    let(:aws_flag) { nil }

    it "raises an error" do
      expect {
        described_class.of_class(node_class)
      }.to raise_error(described_class::MissingConfigurationError)
    end
  end

  context "if the AWS flag is on" do
    let(:aws_flag) { true }

    let(:fetcher_response) {
      %w[
        email_alert_api-1
      ]
    }

    it "uses the AWS fetcher" do
      expect_any_instance_of(described_class::AWSFetcher).to receive(:hostnames_of_class)
        .with(node_class).and_return(fetcher_response)

      expect(described_class.of_class(node_class)).to eq(fetcher_response)
    end
  end

  context "if the AWS flag is off" do
    let(:aws_flag) { false }

    let(:fetcher_response) {
      %w[
        email_alert_api-1
      ]
    }

    it "uses the Carrenza fetcher" do
      expect_any_instance_of(described_class::CarrenzaFetcher).to receive(:hostnames_of_class)
        .with(node_class).and_return(fetcher_response)

      expect(described_class.of_class(node_class)).to eq(fetcher_response)
    end
  end
end
