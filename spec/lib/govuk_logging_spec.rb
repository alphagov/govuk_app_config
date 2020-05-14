require 'spec_helper'
require 'rails'
require 'govuk_app_config/govuk_logging'
require 'rack/test'

RSpec.describe GovukLogging do
  class DummyLoggingRailsApp < Rails::Application
    config.hosts.clear
    routes.draw do
      get '/error', to: proc { |env| raise Exception, "default exception" }
    end
  end

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

  describe '.configure' do
    it 'enables logstasher' do
      Rails.application.config.logstasher.enabled = false
      expect { GovukLogging.configure }
        .to change { Rails.application.config.logstasher.enabled }
        .to(true)
    end

    it 'initialises a logstasher logger using the rails logger level' do
      GovukLogging.configure
      expect(Rails.application.config.logstasher.logger.level)
        .to eq(info_log_level)
    end

    it 'can write to logstasher log' do
      GovukLogging.configure
      logger = Rails.application.config.logstasher.logger
      logger.info('test log entry')
      fake_stdout.rewind

      expect(fake_stdout.read).to match(/test log entry/)
    end

    it 'can write to default rails logger' do
      GovukLogging.configure
      logger = Rails.logger
      logger.info('test default log entry')
      $stderr.rewind

      expect($stderr.read).to match(/test default log entry/)
    end

    describe 'when making requests to the application' do
      include Rack::Test::Methods
      def app
        Rails.application
      end

      it 'logs errors thrown by the application' do
        GovukLogging.configure
        get '/error'
        $stderr.rewind
        expect($stderr.read).to match(/some error/)
      end
    end
  end
end
