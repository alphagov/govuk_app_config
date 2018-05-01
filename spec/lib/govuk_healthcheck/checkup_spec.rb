require "spec_helper"
require "govuk_app_config/govuk_healthcheck"

RSpec.describe GovukHealthcheck::Checkup do
  let(:ok_check) { TestHealthcheck.new(GovukHealthcheck::OK) }
  let(:warning_check) { TestHealthcheck.new(GovukHealthcheck::WARNING) }
  let(:critical_check) { TestHealthcheck.new(GovukHealthcheck::CRITICAL) }

  it "sets the overall status to the worse component status" do
    expect(described_class.new([ok_check]).run[:status]).to eq(GovukHealthcheck::OK)
    expect(described_class.new([ok_check, critical_check]).run[:status]).to eq(GovukHealthcheck::CRITICAL)
    expect(described_class.new([warning_check, critical_check]).run[:status]).to eq(GovukHealthcheck::CRITICAL)
    expect(described_class.new([warning_check, ok_check]).run[:status]).to eq(GovukHealthcheck::WARNING)
  end

  it "sets the specific status of component checks" do
    response = described_class.new([critical_check, warning_check, ok_check]).run
    expect(response.dig(:checks, :ok_check, :status)).to eq(GovukHealthcheck::OK)
  end

  it "includes all statuses in the response" do
    response = described_class.new([critical_check, warning_check, ok_check]).run

    expect(response[:checks]).to have_key(:ok_check)
    expect(response[:checks]).to have_key(:warning_check)
    expect(response[:checks]).to have_key(:critical_check)
  end

  it "puts the details at the top level of each check" do
    response = described_class.new([TestHealthcheckWithDetails.new(GovukHealthcheck::OK)]).run
    expect(response.dig(:checks, :ok_check, :extra)).to eq("This is an extra detail")
  end

  it "adds the message to the check's top level if it supplies one" do
    response = described_class.new([TestHealthcheckWithMessage.new(GovukHealthcheck::OK)]).run
    expect(response.dig(:checks, :ok_check, :message)).to eq("This is a custom message")
  end

  it "leaves out the message key if the check doesn't supply one" do
    response = described_class.new([ok_check]).run
    expect(response.dig(:checks, :ok_check)).not_to have_key(:message)
  end

  class TestHealthcheck
    def initialize(status)
      @status = status
    end

    def name
      "#{status}_check".to_sym
    end

    def status
      @status
    end
  end

  class TestHealthcheckWithMessage < TestHealthcheck
    def message
      "This is a custom message"
    end
  end

  class TestHealthcheckWithDetails < TestHealthcheck
    def details
      {
        extra: "This is an extra detail",
      }
    end
  end
end
