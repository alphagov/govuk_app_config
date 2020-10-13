require "action_dispatch/middleware/debug_exceptions"

module GovukLogging
  module RailsExt
    module ActionDispatch
      def self.should_monkey_patch_log_error?(clazz = ::ActionDispatch::DebugExceptions)
        empty_instance = clazz.new nil
        target_method = empty_instance.method :log_error

        expected_parameters = [%i[req request], %i[req wrapper]]
        actual_parameters = target_method.parameters

        should_monkey_patch = actual_parameters == expected_parameters

        unless should_monkey_patch
          Rails.logger.warn "Refused to monkey patch ::ActionDispatch::DebugExceptions#log_error - " \
            "signatures do not match. " \
            "Expected #{expected_parameters}, but got #{actual_parameters}"
        end

        should_monkey_patch
      rescue StandardError => e
        Rails.logger.warn "Failed to detect whether to monkey patch " \
          "::ActionDispatch::DebugExceptions#log_error - #{e.inspect}"
        false
      end

      def self.monkey_patch_log_error(clazz = ::ActionDispatch::DebugExceptions)
        clazz.class_eval do
          private

          def log_error(request, wrapper)
            logger = logger(request)

            return unless logger

            exception = wrapper.exception

            trace = wrapper.application_trace
            trace = wrapper.framework_trace if trace.empty?

            logger.fatal({
              exception_class: exception.class.to_s,
              exception_message: exception.message,
              stacktrace: trace,
            }.to_json)
          end
        end
      end
    end
  end
end
