require "spec_helper"
require "govuk_app_config/govuk_statsd"

RSpec.describe GovukStatsd do
  describe "#increment" do
    it "increments the counter" do
      expect {
        GovukStatsd.increment("some.key")
      }.not_to raise_error
    end
  end
end
