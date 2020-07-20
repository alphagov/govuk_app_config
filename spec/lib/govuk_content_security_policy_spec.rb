require "spec_helper"
require "rails"
require "govuk_app_config/govuk_content_security_policy"

RSpec.describe GovukContentSecurityPolicy do
  class DummyCspRailsApp < Rails::Application; end

  describe ".configure" do
    it "creates a policy" do
      Rails.application.config.content_security_policy = nil

      expect { GovukContentSecurityPolicy.configure }
        .to change { Rails.application.config.content_security_policy }
        .to(an_instance_of(ActionDispatch::ContentSecurityPolicy))
    end

    it "returns a policy" do
      expect(GovukContentSecurityPolicy.configure)
        .to be_a(ActionDispatch::ContentSecurityPolicy)
    end

    it "can have a report_uri set by an ENV var" do
      ClimateControl.modify(GOVUK_CSP_REPORT_URI: "https://example.com") do
        policy = GovukContentSecurityPolicy.configure
        expect(policy.build).to match("report-uri https://example.com")
      end

      ClimateControl.modify(GOVUK_CSP_REPORT_URI: nil) do
        policy = GovukContentSecurityPolicy.configure
        expect(policy.build).not_to match("report-uri")
      end
    end

    it "can be set to report_only by an ENV var" do
      Rails.application.config.content_security_policy_report_only = false

      ClimateControl.modify(GOVUK_CSP_REPORT_ONLY: "yes") do
        expect { GovukContentSecurityPolicy.configure }
          .to change { Rails.application.config.content_security_policy_report_only }
          .to(true)
      end

      ClimateControl.modify(GOVUK_CSP_REPORT_ONLY: nil) do
        expect { GovukContentSecurityPolicy.configure }
          .to change { Rails.application.config.content_security_policy_report_only }
          .to(false)
      end
    end
  end
end
