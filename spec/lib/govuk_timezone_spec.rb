require "spec_helper"
require "govuk_app_config/govuk_timezone"

RSpec.describe GovukError do
  describe ".configure" do
    let(:logger) { instance_double("ActiveSupport::Logger") }

    before do
      allow(Rails).to receive(:logger).and_return(logger)
    end

    it "should override the default UTC time_zone to London" do
      config = Struct.new(:time_zone).new("UTC")
      expect(logger).to receive(:info)
      GovukTimezone.configure(config)
      expect(config.time_zone).to eq("London")
    end

    it "should allow apps to set time_zone explicitly with config.govuk_time_zone" do
      config = Struct.new(:time_zone, :govuk_time_zone).new("UTC", "Shanghai")
      GovukTimezone.configure(config)
      expect(config.time_zone).to eq("Shanghai")
    end

    it "should default to London if config.govuk_time_zone is nil" do
      config = Struct.new(:time_zone, :govuk_time_zone).new("UTC", nil)
      expect(logger).to receive(:info)
      GovukTimezone.configure(config)
      expect(config.time_zone).to eq("London")
    end

    it "should raise an error if config.time_zone is set to anything other than the default UTC" do
      config = Struct.new(:time_zone).new("London")
      expect { GovukTimezone.configure(config) }.to raise_error(/govuk_app_config prevents configuring time_zone with config[.]time_zone/)
      config = Struct.new(:time_zone).new("Shanghai")
      expect { GovukTimezone.configure(config) }.to raise_error(/govuk_app_config prevents configuring time_zone with config[.]time_zone/)
    end
  end
end
