require "time"

module GovukError
  class GovukDataSync
    class MalformedDataSyncPeriod < RuntimeError
      attr_reader :invalid_value

      def initialize(invalid_value)
        @invalid_value = invalid_value
      end

      def message
        "\"#{invalid_value}\" is not a valid value (should be of form '22:00-03:00')."
      end
    end

    attr_reader :from, :to

    def initialize(govuk_data_sync_period)
      return if govuk_data_sync_period.nil?

      parts = govuk_data_sync_period.split("-")
      raise MalformedDataSyncPeriod, govuk_data_sync_period unless parts.count == 2

      @from, @to = parts.map { |time| Time.parse(time) }
    rescue ArgumentError
      raise MalformedDataSyncPeriod, govuk_data_sync_period
    end

    def in_progress?
      from.present? && to.present? && in_time_range?(from, to)
    end

  private

    # `from`/`to` times are in relation to the local server time, which is expected to be in UTC as per:
    # https://github.com/alphagov/govuk-puppet/blob/b588e4ade996e97b8975e69cb00800521fff4a48/modules/govuk_envsys/files/etc/environment#L3
    def in_time_range?(from, to)
      hour_is_in_range = Time.now.hour >= from.hour || Time.now.hour <= to.hour
      minute_is_in_range = if Time.now.hour == from.hour
                             Time.now.min >= from.min
                           elsif Time.now.hour == to.hour
                             Time.now.min <= to.min
                           else
                             true
                           end
      hour_is_in_range && minute_is_in_range
    end
  end
end
