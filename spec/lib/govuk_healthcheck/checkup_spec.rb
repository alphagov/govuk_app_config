require "spec_helper"
require "govuk_app_config/govuk_healthcheck"

RSpec.describe GovukHealthcheck::Checkup do
  let(:test_healthcheck) do
    Class.new do
      def name
        "#{status}_check".to_sym
      end

      def status
        :unknown
      end
    end
  end

  let(:ok_check) do
    Class.new(test_healthcheck) do
      def status
        :ok
      end
    end
  end

  let(:ok_check_with_message) do
    Class.new(ok_check) do
      def message
        "This is a custom message"
      end
    end
  end

  let(:ok_check_with_details) do
    Class.new(ok_check) do
      def details
        {
          extra: "This is an extra detail",
        }
      end
    end
  end

  let(:warning_check) do
    Class.new(test_healthcheck) do
      def status
        :warning
      end
    end
  end

  let(:critical_check) do
    Class.new(test_healthcheck) do
      def status
        :critical
      end
    end
  end

  let(:disabled_critical_check) do
    Class.new(critical_check) do
      def enabled?
        false
      end
    end
  end

  let(:exception_check) do
    Class.new do
      def name
        :exception_check
      end

      def status
        raise "something bad happened"
      end
    end
  end

  it "sets the overall status to the worse component status" do
    expect(described_class.new([ok_check]).run[:status]).to eq(GovukHealthcheck::OK)
    expect(described_class.new([ok_check, critical_check]).run[:status]).to eq(GovukHealthcheck::CRITICAL)
    expect(described_class.new([warning_check, critical_check]).run[:status]).to eq(GovukHealthcheck::CRITICAL)
    expect(described_class.new([warning_check, ok_check]).run[:status]).to eq(GovukHealthcheck::WARNING)
  end

  it "ignores disabled checks" do
    expect(described_class.new([ok_check, disabled_critical_check]).run[:status]).to eq(GovukHealthcheck::OK)
  end

  it "sets the status as critical for health checks which error" do
    response = described_class.new([exception_check]).run
    expect(response[:status]).to eq(GovukHealthcheck::CRITICAL)
    expect(response.dig(:checks, :exception_check, :message)).to eq("something bad happened")
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
    response = described_class.new([ok_check_with_details]).run
    expect(response.dig(:checks, :ok_check, :extra)).to eq("This is an extra detail")
  end

  it "adds the message to the check's top level if it supplies one" do
    response = described_class.new([ok_check_with_message]).run
    expect(response.dig(:checks, :ok_check, :message)).to eq("This is a custom message")
  end

  it "leaves out the message key if the check doesn't supply one" do
    response = described_class.new([ok_check]).run
    expect(response.dig(:checks, :ok_check)).not_to have_key(:message)
  end

  it "sets the message of disabled checks" do
    response = described_class.new([disabled_critical_check]).run
    expect(response.dig(:checks, :critical_check, :message)).to eq("currently disabled")
  end

  it "sets the status of disabled checks to ok" do
    response = described_class.new([disabled_critical_check]).run
    expect(response.dig(:checks, :critical_check, :status)).to eq(:ok)
  end

  it "accepts objects (can be initialized)" do
    response = described_class.new([test_healthcheck.new]).run
    expect(response.dig(:checks, :unknown_check, :status)).to eq(:unknown)
  end
end
