require "aws-sdk-ec2"

class GovukNodes
  class AWSFetcher
    def hostnames_of_class(node_class)
      instances_of_class(node_class).map(&:private_dns_name)
    end

  private

    def ec2
      @ec2 ||= Aws::EC2::Client.new
    end

    def stack_name
      @stack_name ||= ENV["AWS_STACKNAME"]
    end

    def filter(name, value)
      { name: name, values: [value] }
    end

    def instances_of_class(node_class)
      ec2.describe_instances(
        filters: [
          filter("tag:aws_stackname", stack_name),
          filter("tag:aws_migration", node_class.tr("-", "_")),
          filter("instance-state-name", "running"),
        ],
      ).reservations.flat_map(&:instances)
    end
  end
end
