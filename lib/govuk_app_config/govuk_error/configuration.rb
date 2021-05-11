require "delegate"
require "govuk_app_config/govuk_error/govuk_data_sync"

module GovukError
  class Configuration < SimpleDelegator
    attr_reader :data_sync, :sentry_environment
    attr_accessor :active_sentry_environments, :data_sync_excluded_exceptions

    def initialize(_raven_configuration)
      super
      @sentry_environment = ENV["SENTRY_CURRENT_ENV"]
      @data_sync = GovukDataSync.new(ENV["GOVUK_DATA_SYNC_PERIOD"])
      self.active_sentry_environments = []
      self.data_sync_excluded_exceptions = []
      @before_send_callbacks = [
        ignore_exceptions_based_on_env_and_data_sync,
        increment_govuk_statsd_counters,
      ]
      super.before_send = run_before_send_callbacks
    end

    def before_send=(closure)
      @before_send_callbacks.insert(-2, closure)
    end

  protected

    def ignore_exceptions_based_on_env_and_data_sync
      lambda do |error_or_event, hint|
        error_or_event if ignore_exceptions_if_not_in_active_sentry_env.call(error_or_event, hint) &&
          ignore_excluded_exceptions_in_data_sync.call(error_or_event, hint)
      end
    end

    def ignore_exceptions_if_not_in_active_sentry_env
      ->(_error_or_event, _hint) { active_sentry_environments.include?(sentry_environment) }
    end

    def ignore_excluded_exceptions_in_data_sync
      lambda { |error_or_event, _hint|
        data_sync_ignored_error = data_sync_excluded_exceptions.any? do |exception_to_ignore|
          exception_to_ignore = Object.const_get(exception_to_ignore) unless exception_to_ignore.is_a?(Module)
          exception_chain = Raven::Utils::ExceptionCauseChain.exception_to_array(error_or_event)
          exception_chain.any? { |exception| exception.is_a?(exception_to_ignore) }
        rescue NameError
          # the exception type represented by the exception_to_ignore string
          # doesn't even exist in this environment, so won't be found in the chain
          false
        end

        !(data_sync.in_progress? && data_sync_ignored_error)
      }
    end

    def increment_govuk_statsd_counters
      lambda { |error_or_event, _hint|
        GovukStatsd.increment("errors_occurred")
        GovukStatsd.increment("error_types.#{error_or_event.class.name.demodulize.underscore}")
        error_or_event
      }
    end

    def run_before_send_callbacks
      lambda do |error_or_event, hint|
        @before_send_callbacks.each do |callback|
          break if callback.call(error_or_event, hint).nil?
        end
        error_or_event
      end
    end
  end
end
