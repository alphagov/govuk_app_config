require "spec_helper"
require "rails"
require "govuk_app_config/govuk_json_logging"
require "rack/test"

RSpec.describe GovukJsonLogging do
  before do
    stub_const("DummyLoggingRailsApp", Class.new(Rails::Application) do
      config.hosts.clear
      routes.draw do
        get "/error", to: proc { |_env| raise StandardError, "default exception" }
      end
    end)
  end

  after { Rails.application = nil }

  old_stderr = nil

  let(:fake_stdout) { StringIO.new }
  let(:info_log_level) { 1 }

  before do
    old_stderr = $stderr
    $stderr = StringIO.new
    allow($stdout).to receive(:clone).and_return(fake_stdout)
    allow($stdout).to receive(:reopen)
    Rails.logger = Logger.new(fake_stdout, level: info_log_level)
  end

  after do
    $stderr = old_stderr
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
      $stderr.rewind

      expect($stderr.read).to match(/test default log entry/)
    end

    describe "when making requests to the application" do
      include Rack::Test::Methods

      def app
        Rails.application
      end

      it "logs errors thrown by the application" do
        GovukJsonLogging.configure
        get "/error"
        $stderr.rewind
        lines = $stderr.read.split("\n")
        expect(lines).to include(/default exception/)
        error_log_line = lines.find { |log| log.match?(/default exception/) }
        expect(error_log_line).not_to be_empty
        error_log_json = JSON.parse(error_log_line)
        expect(error_log_json).to match(hash_including(
                                          "exception_class" => "StandardError",
                                          "exception_message" => "default exception",
                                        ))
        expect(error_log_json).to have_key("stacktrace")
        expect(error_log_json["stacktrace"]).to be_a(Array)
      end
    end
  end
end
