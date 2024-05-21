# This is copied from
# https://github.com/shadabahmed/logstasher/blob/main/lib/logstasher/rails_ext/action_controller/metal/instrumentation.rb
# Changes have been highlight in comments, otherwise the code is the same.

module ActionController
  module Instrumentation
    alias_method "orig_process_action", "process_action"

    def process_action(*args)
      # The raw payload has been updated to reflect the payload structure used
      # in Rails 7.1, primarily the addition of the `headers`, `request` keys
      # and using `request.filtered_path` instead of `request.fullpath`.
      # https://github.com/rails/rails/blame/d39db5d1891f7509cde2efc425c9d69bbb77e670/actionpack/lib/action_controller/metal/instrumentation.rb#L60
      raw_payload = {
        controller: self.class.name,
        action: action_name,
        request:,
        params: request.filtered_parameters,
        headers: request.headers,
        format: request.format.ref,
        method: request.request_method,
        path: begin
          request.filtered_path
        rescue StandardError
          "unknown"
        end,
      }

      LogStasher.add_default_fields_to_payload(raw_payload, request)

      LogStasher.clear_request_context
      LogStasher.add_default_fields_to_request_context(request)

      ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload.dup)

      ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
        if respond_to?(:logstasher_add_custom_fields_to_request_context)
          logstasher_add_custom_fields_to_request_context(LogStasher.request_context)
        end

        if respond_to?(:logstasher_add_custom_fields_to_payload)
          before_keys = raw_payload.keys.clone
          logstasher_add_custom_fields_to_payload(raw_payload)
          after_keys = raw_payload.keys
          # Store all extra keys added to payload hash in payload itself. This is a thread safe way
          LogStasher::CustomFields.add(*(after_keys - before_keys))
        end

        result = super

        payload[:status] = response.status
        append_info_to_payload(payload)
        LogStasher.store.each do |key, value|
          payload[key] = value
        end

        LogStasher.request_context.each do |key, value|
          payload[key] = value
        end
        result
      end
    end
    alias_method "logstasher_process_action", "process_action"
  end
end
