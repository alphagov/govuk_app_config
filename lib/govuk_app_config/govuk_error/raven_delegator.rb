module GovukError
  class RavenDelegator < SimpleDelegator
    def should_capture=(closure)
      if should_capture.present?
        previous_closure = should_capture
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
