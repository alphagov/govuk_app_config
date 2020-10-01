require "spec_helper"
require "rails"
require "govuk_app_config/default_configuration"

RSpec.describe DefaultConfiguration do
  let(:sentry_client) do
    methods_to_stub = %w[
      before_send=
      silence_ready=
      excluded_exceptions=
      inspect_exception_causes_for_exclusion=
      transport_failure_callback=
      should_capture=
    ]
    dbl = double("Raven")
    methods_to_stub.each { |method| allow(dbl).to receive(method.to_sym) }
    dbl
  end

  describe ".silence_ready" do
    it "is not set if we are not in a Rails environment" do
      hide_const("Rails")
      expect(sentry_client).to_not receive(:silence_ready=)
      DefaultConfiguration.new(sentry_client)
    end

    context "we are in a Rails environment" do
      let!(:cached_rails_env) { Rails.env }
      after { Rails.env = cached_rails_env }

      it "is false in production" do
        Rails.env = "production"
        expect(sentry_client).to receive(:silence_ready=).with(false)
        DefaultConfiguration.new(sentry_client)
      end

      it "is true when not in production" do
        Rails.env = "development"
        expect(sentry_client).to receive(:silence_ready=).with(true)
        DefaultConfiguration.new(sentry_client)
      end
    end
  end

  describe ".should_capture" do
    # mock the PG::Error class so we don't have to pull it in
    module PG; class Error; end; end

    it "captures PostgreSQL errors that occur outside of the data sync time window" do
      expect(error_of_type(PG::Error.new).occurring_at(hour: 21).should_capture).to eq(true)
    end

    it "ignores PostgreSQL errors that occur during the data sync time window" do
      expect(error_of_type(PG::Error.new).occurring_at(hour: 22).should_capture).to eq(false)
    end

    it "captures non-PostgreSQL errors that occur during the data sync time window" do
      expect(error_of_type(StandardError.new).occurring_at(hour: 22).should_capture).to eq(true)
    end

    def error_of_type(error)
      @error = error
      self
    end

    def occurring_at(time)
      @time = time
      self
    end

    def should_capture
      the_lambda = nil
      allow(sentry_client).to receive(:should_capture=) { |callback| the_lambda = callback }
      DefaultConfiguration.new(sentry_client)
      expect(the_lambda).not_to be_nil
      travel_to(Time.current.change(@time)) { the_lambda.call(@error) }
    end
  end
end
