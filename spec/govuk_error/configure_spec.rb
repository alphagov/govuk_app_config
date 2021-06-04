require "spec_helper"
require "sentry-ruby"
require "govuk_app_config/govuk_error"

RSpec.describe "GovukError.configure" do
  it "should contain only valid Sentry config" do
    require "govuk_app_config/govuk_error/configure"
  end
end
