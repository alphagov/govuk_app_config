require "spec_helper"
require "govuk_app_config/govuk_healthcheck"

RSpec.describe GovukHealthcheck::Checkup do
  let(:ok_check) { OkTestHealthcheck }
  let(:warning_check) { WarningTestHealthcheck }
  let(:critical_check) { CriticalTestHealthcheck }
  let(:disabled_critical_check) { DisabledCriticalHealthcheck }

  it "sets the overall status to the worse component status" do
    expect(described_class.new([ok_check]).run[:status]).to eq(GovukHealthcheck::OK)
    expect(described_class.new([ok_check, critical_check]).run[:status]).to eq(GovukHealthcheck::CRITICAL)
    expect(described_class.new([warning_check, critical_check]).run[:status]).to eq(GovukHealthcheck::CRITICAL)
    expect(described_class.new([warning_check, ok_check]).run[:status]).to eq(GovukHealthcheck::WARNING)
  end

  it "ignores disabled checks" do
    expect(described_class.new([ok_check, disabled_critical_check]).run[:status]).to eq(GovukHealthcheck::OK)
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
    response = described_class.new([OkTestHealthcheckWithDetails]).run
    expect(response.dig(:checks, :ok_check, :extra)).to eq("This is an extra detail")
  end

  it "adds the message to the check's top level if it supplies one" do
    response = described_class.new([OkTestHealthcheckWithMessage]).run
    expect(response.dig(:checks, :ok_check, :message)).to eq("This is a custom message")
  end

  it "leaves out the message key if the check doesn't supply one" do
    response = described_class.new([ok_check]).run
    expect(response.dig(:checks, :ok_check)).not_to have_key(:message)
  end

  it "sets the message of disabled checks" do
    response = described_class.new([DisabledCriticalHealthcheck]).run
    expect(response.dig(:checks, :critical_check, :message)).to eq("currently disabled")
  end

  it "sets the status of disabled checks to ok" do
    response = described_class.new([DisabledCriticalHealthcheck]).run
    expect(response.dig(:checks, :critical_check, :status)).to eq(:ok)
  end

  class TestHealthcheck
    def name
      "#{status}_check".to_sym
    end
  end

  class OkTestHealthcheck < TestHealthcheck
    def status
      :ok
    end
  end

  class WarningTestHealthcheck < TestHealthcheck
    def status
      :warning
    end
  end

  class CriticalTestHealthcheck < TestHealthcheck
    def status
      :critical
    end
  end

  class OkTestHealthcheckWithMessage < OkTestHealthcheck
    def message
      "This is a custom message"
    end
  end

  class OkTestHealthcheckWithDetails < OkTestHealthcheck
    def details
      {
        extra: "This is an extra detail",
      }
    end
  end

  class DisabledCriticalHealthcheck < CriticalTestHealthcheck
    def enabled?
      false
    end
  end
end
