require "spec_helper"
require "govuk_app_config/govuk_error"

RSpec.describe GovukError do
  describe ".notify" do
    it "forwards the exception" do
      allow(Sentry).to receive(:capture_exception)

      GovukError.notify(StandardError.new)

      expect(Sentry).to have_received(:capture_exception)
    end

    it "allows Airbrake-style parameters" do
      allow(Sentry).to receive(:capture_exception)

      GovukError.notify(StandardError.new, parameters: "Something")

      expect(Sentry).to have_received(:capture_exception).with(StandardError.new, hash_including(extra: { parameters: "Something" }))
    end

    it "sends the version along with the request" do
      allow(Sentry).to receive(:capture_exception)

      GovukError.notify(StandardError.new, parameters: "Something")

      expect(Sentry).to have_received(:capture_exception).with(StandardError.new, hash_including(tags: { govuk_app_config_version: /^[0-9]\.[0-9]\.[0-9](?:\.pre\.[0-9]+)?$/ }))
    end
  end

  describe ".configure" do
    it "configures Sentry via the Configuration" do
      expect { |b| GovukError.configure(&b) }
        .to yield_with_args(instance_of(GovukError::Configuration))
    end
  end

  describe ".init" do
    let(:dummy_dsn) { "http://12345:67890@sentry.localdomain/sentry/42" }

    it "calls Sentry.init" do
      expect(Sentry).to receive(:init).once
      GovukError.init
    end

    it "configures Sentry with all previous GovukError.configure calls" do
      stub_const("ErrorWeWantToIgnore", Class.new(StandardError))
      stub_const("DataSyncIgnorableError", Class.new(StandardError))
      stub_request(:post, "http://sentry.localdomain/sentry/api/42/envelope/").to_return(status: 200)

      ClimateControl.modify SENTRY_CURRENT_ENV: "integration-blue-aws", GOVUK_DATA_SYNC_PERIOD: "22:00-08:00" do
        travel_to(Time.current.change(hour: 23)) do
          GovukError.configure do |config|
            config.excluded_exceptions = %w[Foo]
          end
          GovukError.configure do |config|
            config.excluded_exceptions += %w[Bar]
            config.enabled_environments = %w[integration-blue-aws]
            config.data_sync_excluded_exceptions = %w[DataSyncIgnorableError]
            config.before_send = lambda do |event, hint|
              hint[:exception].is_a?(ErrorWeWantToIgnore) ? nil : event
            end

            # some hackery to get the test to work
            config.dsn = dummy_dsn
            config.transport.transport_class = Sentry::DummyTransport
            # so the events will be sent synchronously for testing
            config.background_worker_threads = 0
          end
          GovukError.init

          client = Sentry.get_current_client
          expect(client.configuration.sending_allowed?).to eq(true)
          expect(client.configuration.excluded_exceptions).to eq(%w[Foo Bar])

          # NOTE: we can't call this getter method as Sentry::Configuration hasn't defined it
          # expect(config.data_sync_excluded_exceptions).to eq(%w[Baz])

          expect { Sentry.capture_exception(ErrorWeWantToIgnore.new("Dummy exception")) }
            .to change { client.transport.events.count }
            .by(0)

          # @TODO - this assertion fails with this seed:
          #     bundle exec rspec --seed 12454
          # ...but passes with this seed:
          #     bundle exec rspec --seed 30962
          expect { Sentry.capture_exception(DataSyncIgnorableError.new("Exception we want to ignore during data sync")) }
            .to change { client.transport.events.count }
            .by(0)
          expect { Sentry.capture_exception(StandardError.new("Real exception")) }
            .to change { client.transport.events.count }
            .by(1)
        end
      end
    end
  end
end
