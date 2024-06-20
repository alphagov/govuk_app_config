require "spec_helper"
require "govuk_app_config/govuk_timezone"

RSpec.describe GovukError do
  describe ".configure" do
    it "should set time_zone to London" do
      config = double(:config)
      expect(config).to receive(:time_zone=).with("London")
      GovukTimezone.configure(config)
    end
  end
end
