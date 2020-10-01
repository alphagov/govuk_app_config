module GovukError
  class Configuration < SimpleDelegator
    def should_capture=(closure)
      # rubocop:disable Style/RedundantSelf
      if self.should_capture.present?
        previous_closure = self.should_capture
        # rubocop:enable Style/RedundantSelf
        combined = lambda do |error_or_event|
          (previous_closure.call(error_or_event) && closure.call(error_or_event))
        end
        super(combined)
      else
        super(closure)
      end
    end
  end
end
