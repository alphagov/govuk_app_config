require "spec_helper"

require "govuk_app_config/govuk_nodes/aws_fetcher"

RSpec.describe GovukNodes::AWSFetcher do
  let(:node_class) { "email_alert_api" }
  let(:stack_name) { "green" }

  let!(:aws_client) {
    Aws::EC2::Client.new(stub_responses: {
      describe_instances: {
        reservations: [
          ec2_reservation("email_alert_api-1"),
          ec2_reservation("email_alert_api-2"),
        ],
      },
    })
  }

  let(:empty_result) {
    Aws::EC2::Types::DescribeInstancesResult.new(reservations: [])
  }

  subject { described_class.new }

  before do
    allow(Aws::EC2::Client).to receive(:new).and_return(aws_client)
  end

  around do |example|
    ClimateControl.modify AWS_STACKNAME: stack_name do
      example.run
    end
  end

  describe "#hostnames_of_class(node_class)" do
    it "queries AWS for the nodes" do
      expect(aws_client).to receive(:describe_instances).with(
        filters: [
          { name: "tag:aws_stackname", values: [stack_name] },
          { name: "tag:aws_migration", values: [node_class] },
          { name: "instance-state-name", values: ["running"] },
        ]
      ).and_return(empty_result)

      subject.hostnames_of_class(node_class)
    end

    it "allows underscores or hyphens" do
      expect(aws_client).to receive(:describe_instances).with(
        filters: array_including(
          { name: "tag:aws_migration", values: [node_class] },
        )
      ).and_return(empty_result)
      subject.hostnames_of_class("email_alert_api")

      expect(aws_client).to receive(:describe_instances).with(
        filters: array_including(
          { name: "tag:aws_migration", values: [node_class] },
        )
      ).and_return(empty_result)
      subject.hostnames_of_class("email-alert-api")
    end

    it "returns the names of the instances found" do
      expect(subject.hostnames_of_class(node_class)).to match_array(%w[
        email_alert_api-1
        email_alert_api-2
      ])
    end

    context "when the response is a 500" do
      let(:response_code) { 500 }

      it "raises exceptions" do
        aws_client.stub_responses(:describe_instances, {
          status_code: response_code,
          headers: {},
          body: "",
        })

        expect {
          subject.hostnames_of_class(node_class)
        }.to raise_error(Aws::Errors::ServiceError)
      end
    end

    context "when the response is a 400" do
      let(:response_code) { 403 }

      it "raises an exception" do
        aws_client.stub_responses(:describe_instances,
          status_code: response_code,
          headers: {},
          body: "",
        )

        expect {
          subject.hostnames_of_class(node_class)
        }.to raise_error(Aws::Errors::ServiceError)
      end
    end

    context "when the response is a 300" do
      let(:response_code) { 302 }

      it "raises an exception" do
        aws_client.stub_responses(:describe_instances,
          status_code: response_code,
          headers: {},
          body: "",
        )

        expect {
          subject.hostnames_of_class(node_class)
        }.to raise_error(Aws::Errors::ServiceError)
      end
    end
  end
end
