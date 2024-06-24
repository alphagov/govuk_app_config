require "spec_helper"
require "govuk_app_config/govuk_timezone"

RSpec.describe GovukError do
  describe ".configure" do
    let(:config) { Rails::Railtie::Configuration.new }
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

    it "should leave time_zones set to London as London" do
      config.time_zone = "London"
      expect(logger).to receive(:info)
      GovukTimezone.configure(config)
      expect(config.time_zone).to eq("London")
    end

    it "should raise an error if configured with any other time zone" do
      config.time_zone = "Shanghai"
      expect { GovukTimezone.configure(config) }.to raise_error(/govuk_app_config prevents configuring time_zones/)
    end
  end
end
