require 'spec_helper'
require 'rails'
require 'govuk_app_config/govuk_content_security_policy'

RSpec.describe GovukContentSecurityPolicy do
  class DummyCspRailsApp < Rails::Application; end

  describe '.configure' do
    it 'creates a policy' do
      Rails.application.config.content_security_policy = nil

      expect { GovukContentSecurityPolicy.configure }
        .to change { Rails.application.config.content_security_policy }
        .to(an_instance_of(ActionDispatch::ContentSecurityPolicy))
    end

    it 'returns a policy' do
      expect(GovukContentSecurityPolicy.configure)
        .to be_a(ActionDispatch::ContentSecurityPolicy)
    end
  end
end
