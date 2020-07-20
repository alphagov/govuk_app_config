require "spec_helper"
require "rails"
require "govuk_app_config/rails_ext/action_dispatch/debug_exceptions"

RSpec.describe ::GovukLogging::RailsExt::ActionDispatch do
  describe "#should_monkey_patch_log_error?" do
    before do
      Rails.logger = double(:rails_logger)
      allow(Rails.logger).to receive(:warn)
    end

    it "should not monkey patch classes which do not have log_error" do
      class NoMethodTestClass; end
      expect(described_class.should_monkey_patch_log_error?(NoMethodTestClass)).to be(false)
    end

    it "should not monkey patch classes which have log_error with different params" do
      class WrongParametersTestClass
      private

        def log_error(_different, _parameters); end
      end
      expect(described_class.should_monkey_patch_log_error?(WrongParametersTestClass)).to be(false)
    end

    it "should monkey patch classes which have log_error with the same params" do
      class RightParametersTestClass
      private

        def log_error(request, wrapper); end
      end
      expect(described_class.should_monkey_patch_log_error?(RightParametersTestClass)).to be(false)
    end
  end

  describe "#monkey_patch_log_error" do
    it "should replace the private log_error method" do
      class FakeDebugExceptions
        def log_error(request, wrapper); end
      end
      instance = FakeDebugExceptions.new

      expect {
        described_class.monkey_patch_log_error(FakeDebugExceptions)
      }.to change {
        instance.method(:log_error)
      }
    end
  end
end
