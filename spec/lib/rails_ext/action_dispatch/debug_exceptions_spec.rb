require "spec_helper"
require "rails"
require "govuk_app_config/rails_ext/action_dispatch/debug_exceptions"

RSpec.describe ::GovukJsonLogging::RailsExt::ActionDispatch do
  describe "#should_monkey_patch_log_error?" do
    before do
      Rails.logger = double(:rails_logger)
      allow(Rails.logger).to receive(:warn)
    end

    after do
      Rails.logger = nil
    end

    it "should not monkey patch classes which do not have log_error" do
      no_method_test_class = Class.new
      expect(described_class.should_monkey_patch_log_error?(no_method_test_class)).to be(false)
    end

    it "should not monkey patch classes which have log_error with different params" do
      wrong_parameters_test_class = Class.new do
        def log_error(_different, _parameters); end
      end
      expect(described_class.should_monkey_patch_log_error?(wrong_parameters_test_class)).to be(false)
    end

    it "should monkey patch classes which have log_error with the same params" do
      right_parameters_test_class = Class.new do
        def log_error(request, wrapper); end
      end
      expect(described_class.should_monkey_patch_log_error?(right_parameters_test_class)).to be(false)
    end
  end

  describe "#monkey_patch_log_error" do
    it "should replace the private log_error method" do
      fake_debug_exceptions = Class.new do
        def log_error(request, wrapper); end
      end
      instance = fake_debug_exceptions.new

      expect {
        described_class.monkey_patch_log_error(fake_debug_exceptions)
      }.to(change { instance.method(:log_error) })
    end
  end
end
