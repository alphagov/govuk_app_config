require "spec_helper"
require "rails"
require "govuk_app_config/govuk_json_logging"
require "rack/test"

class TestController < ActionController::Base
  include LogStasher::ActionController::Instrumentation
  def index; end
end

RSpec.describe GovukJsonLogging do
  let(:govuk_headers_class) do
    Class.new do
      def self.headers
        { govuk_request_id: "some-value" }
      end
    end
  end
  before do
    stub_const("DummyLoggingRailsApp", Class.new(Rails::Application) do
      config.hosts.clear
      routes.draw do
        get "/error", to: proc { |_env| raise StandardError, "default exception" }
      end
    end)
  end

  after { Rails.application = nil }

  # By storing origin stdout in a constant and redirect `$stdout` to a fake one,
  # We are able to inspect and test what is printed
  # BUT it also suppress all the normal log outputs
  # I.E. puts doesn't work anymore :D
  original_stderr = nil
  original_stdout = nil

  let(:fake_stdout) { StringIO.new }
  let(:fake_stderr) { StringIO.new }
  let(:info_log_level) { 1 }

  before do
    original_stderr = $stderr
    original_stdout = $stdout
    $stderr = fake_stderr
    $stdout = fake_stdout
    Rails.logger = Logger.new(fake_stdout, level: info_log_level)
  end

  after do
    $stderr = original_stderr
    $stdout = original_stdout
  end

  describe ".configure" do
    it "enables logstasher" do
      Rails.application.config.logstasher.enabled = false
      expect { GovukJsonLogging.configure }
        .to change { Rails.application.config.logstasher.enabled }
        .to(true)
    end

    it "initialises a logstasher logger using the rails logger level" do
      GovukJsonLogging.configure
      expect(Rails.application.config.logstasher.logger.level)
        .to eq(info_log_level)
    end

    it "can write to logstasher log" do
      GovukJsonLogging.configure
      logger = Rails.application.config.logstasher.logger
      logger.info("test log entry")
      fake_stdout.rewind

      expect(fake_stdout.read).to match(/test log entry/)
    end

    it "can write to default rails logger" do
      GovukJsonLogging.configure
      logger = Rails.logger
      logger.info("test default log entry")
      fake_stdout.rewind

      expect(fake_stdout.read).to match(/test default log entry/)
    end

    context "given a block" do
      it "evals the block" do
        done = false
        expect {
          GovukJsonLogging.configure do
            done = true
          end
        }.to change { done }.to(true)
      end

      context "and the block configures custom fields" do
        describe "any subsequently-created ActionController" do
          let(:headers) { { "REMOTE_ADDR" => "10.10.10.10" } }
          let(:mock_request) { ActionDispatch::TestRequest.new(Rack::MockRequest.env_for("http://example.com:8080/", headers)) }
          let(:mock_response) { ActionDispatch::TestResponse.new }

          before do
            GovukJsonLogging.configure do
              add_custom_fields do |fields|
                fields[:govuk_custom_field] = request.headers["GOVUK-Custom-Header"]
              end
            end

            @controller = TestController.new
            allow(@controller).to receive(:request).and_return(mock_request)
            allow(@controller).to receive(:response).and_return(mock_response)
          end

          it "has a logstasher_add_custom_fields_to_payload method" do
            expect(@controller.methods).to include(:logstasher_add_custom_fields_to_payload)
          end

          describe "calling the logstasher_add_custom_fields_to_payload" do
            let(:payload) { {} }

            it "executes the block" do
              expect(@controller).to receive(:logstasher_add_custom_fields_to_payload)
              @controller.send(:append_info_to_payload, payload)
            end

            it "adds the custom fields to the payload" do
              @controller.send(:append_info_to_payload, payload)
              expect(payload.keys).to include(:govuk_custom_field)
            end

            context "when the custom field has a value" do
              before do
                mock_request.headers["GOVUK-Custom-header"] = "My header value"
              end

              it "sets the custom field value in the payload" do
                @controller.send(:append_info_to_payload, payload)
                expect(payload[:govuk_custom_field]).to eq("My header value")
              end
            end
          end
        end
      end
    end

    describe "when making requests to the application" do
      include Rack::Test::Methods

      def app
        Rails.application
      end

      it "logs errors thrown by the application with govuk_request_id" do
        stub_const("GdsApi::GovukHeaders", govuk_headers_class)
        GovukJsonLogging.configure
        get "/error"
        fake_stdout.rewind
        lines = fake_stdout.read.split("\n")
        expect(lines).to include(/default exception/)
        error_log_line = lines.find { |log| log.match?(/default exception/) }
        expect(error_log_line).not_to be_empty

        error_log_json = JSON.parse(error_log_line)
        expect(error_log_json).to match(hash_including(
                                          "govuk_request_id" => "some-value",
                                        ))

        error_log_json_msg = error_log_json["message"]
        expect(error_log_json_msg).to include("StandardError")
        expect(error_log_json_msg).to include("default exception")
        expect(error_log_json_msg).to match(/[a-zA-Z]+.*:[0-9]+:in.*/)
      end

      it "logs errors thrown by the application with no govuk_request_id" do
        GovukJsonLogging.configure
        get "/error"
        fake_stdout.rewind
        lines = fake_stdout.read.split("\n")
        expect(lines).to include(/default exception/)
        error_log_line = lines.find { |log| log.match?(/default exception/) }
        expect(error_log_line).not_to be_empty
        error_log_json = JSON.parse(error_log_line)
        error_log_json_msg = error_log_json["message"]
        expect(error_log_json_msg).to include("StandardError")
        expect(error_log_json_msg).to include("default exception")
        expect(error_log_json_msg).to match(/[a-zA-Z].*:[0-9]+:in.*/)
      end

      it "logs to stdout in JSON format with govuk_request_id" do
        stub_const("GdsApi::GovukHeaders", govuk_headers_class)
        GovukJsonLogging.configure
        logger = Rails.logger
        logger.info("test default log entry")
        fake_stdout.rewind
        log_line = fake_stdout.read
        log_json = JSON.parse(log_line)

        expect(log_json).to include("message" => "test default log entry")
        expect(log_json).to include("govuk_request_id" => "some-value")
      end
    end
  end
end
