require 'spec_helper'

RSpec.describe 'Requiring govuk_app_config' do
  it 'correctly initialises error tracking' do
    ClimateControl.modify SENTRY_CURRENT_ENV: 'integration-or-somesuch' do
      require 'govuk_app_config'

      expect(Raven.configuration.current_environment).to eql('integration-or-somesuch')
      expect { Raven.configuration.should_capture.call('foo') }.not_to raise_error
      expect { Raven.configuration.transport_failure_callback.call('foo') }.not_to raise_error
    end
  end

  describe 'configuring capture filters' do
    before(:each) do
      GovukError.configuration.clear_capture_filters
    end

    it 'can accept a single capture filter' do
      require 'govuk_app_config'

      filter_helper = spy('filter_helper')

      GovukError.configure do |config|
        config.add_capture_filter do |error|
          filter_helper.should_capture?(error)
          true
        end
      end

      should_capture = Raven.configuration.should_capture.call('some_error')

      expect(filter_helper).to have_received(:should_capture?).with('some_error')
      expect(should_capture).to be(true)
    end

    it 'can accept two capture filters' do
      require 'govuk_app_config'

      filter_helper = spy('filter_helper')

      GovukError.configure do |config|
        config.add_capture_filter do |error|
          filter_helper.method1(error)
          true
        end

        config.add_capture_filter do |error|
          filter_helper.method2(error)
          true
        end
      end

      should_capture = Raven.configuration.should_capture.call('some_error')

      expect(filter_helper).to have_received(:method1).with('some_error')
      expect(filter_helper).to have_received(:method2).with('some_error')
      expect(should_capture).to be(true)
    end

    it 'should capture when no filters are configured' do
      require 'govuk_app_config'

      should_capture = Raven.configuration.should_capture.call('some_error')

      expect(should_capture).to be(true)
    end

    it 'should not capture when a filter returns false' do
      require 'govuk_app_config'

      GovukError.configure do |config|
        config.add_capture_filter { true }
        config.add_capture_filter { false }
        config.add_capture_filter { true }
      end

      should_capture = Raven.configuration.should_capture.call('some_error')

      expect(should_capture).to be(false)
    end
  end

  # Reopen the class to add the ability to clear the capture filters between tests.
  # We don't want this function available in production, because it will clear the
  # extra capture filter applied in configure.rb, and there should never be any
  # need to clear the filters.
  module GovukError
    class Configuration
      def clear_capture_filters
        @capture_filters = []
      end
    end
  end
end
