require_relative "govuk_nodes/aws_fetcher"
require_relative "govuk_nodes/carrenza_fetcher"

class GovukNodes
  class <<self
    def configure
      yield self
    end

    def aws?
      if @is_aws.nil?
        message = "Please configure the platform flag `is_aws` before using #{name}"
        raise MissingConfigurationError.new(message)
      end

      @is_aws
    end

    attr_writer :is_aws

    def of_class(node_class)
      self.new.of_class(node_class)
    end
  end

  def of_class(node_class)
    fetcher.hostnames_of_class(node_class)
  end

private

  def fetcher
    @fetcher ||= if self.class.aws?
      GovukNodes::AWSFetcher.new
    else
      GovukNodes::CarrenzaFetcher.new
    end
  end

  class MissingConfigurationError < StandardError; end
end
