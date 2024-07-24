require "ostruct"
require "spec_helper"
require "govuk_app_config/govuk_timezone"

RSpec.describe GovukError do
  describe ".configure" do
    let(:config) { OpenStruct.new }
    let(:logger) { instance_double("ActiveSupport::Logger") }

    before do
      allow(Rails).to receive(:logger).and_return(logger)
    end

    it "should override the default UTC time_zone to London" do
      config.time_zone = "UTC"
      expect(logger).to receive(:info)
      GovukTimezone.configure(config)
      expect(config.time_zone).to eq("London")
    end

    it "should allow apps to set time_zone explicitly with config.govuk_time_zone" do
      config.time_zone = "UTC"
      config.govuk_time_zone = "Shanghai"
      GovukTimezone.configure(config)
      expect(config.time_zone).to eq("Shanghai")
    end

    it "should default to London if config.govuk_time_zone is nil" do
      config.time_zone = "UTC"
      config.govuk_time_zone = nil
      expect(logger).to receive(:info)
      GovukTimezone.configure(config)
      expect(config.time_zone).to eq("London")
    end

    it "should raise an error if config.time_zone is set to anything other than the default UTC" do
      config.time_zone = "London"
      expect { GovukTimezone.configure(config) }.to raise_error(/govuk_app_config prevents configuring time_zone with config[.]time_zone/)
      config.time_zone = "Shanghai"
      expect { GovukTimezone.configure(config) }.to raise_error(/govuk_app_config prevents configuring time_zone with config[.]time_zone/)
    end
  end
end
