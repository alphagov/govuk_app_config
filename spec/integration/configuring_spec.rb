require 'spec_helper'

RSpec.describe 'Requiring govuk_config' do
  it 'correctly initialises error tracking' do
    ClimateControl.modify SENTRY_CURRENT_ENV: 'integration-or-somesuch' do
      require 'govuk_config'

      expect(Raven.configuration.current_environment).to eql('integration-or-somesuch')
      expect { Raven.configuration.should_capture.call('foo') }.not_to raise_error
      expect { Raven.configuration.transport_failure_callback.call('foo') }.not_to raise_error
    end
  end
end
