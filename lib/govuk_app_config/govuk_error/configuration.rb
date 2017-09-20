module GovukError
  class Configuration
    attr_reader :capture_filters

    def initialize
      @capture_filters = []
    end

    def add_capture_filter(&block)
      @capture_filters << block
    end
  end
end
