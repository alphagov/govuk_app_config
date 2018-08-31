module EC2Helper
  # Source:
  # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/Reservation.html
  # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Reservation.html
  # https://raw.githubusercontent.com/aws/aws-sdk-ruby/7f668900dd8603d6820c97779ae36ceb14c7a1ca/gems/aws-sdk-ec2/lib/aws-sdk-ec2/types.rb
  def ec2_reservation(instance_name)
    {
      instances: [ec2_instance(instance_name)],
    }
  end

  # Source:
  # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/Instance.html
  # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Instance.html
  # https://raw.githubusercontent.com/aws/aws-sdk-ruby/7f668900dd8603d6820c97779ae36ceb14c7a1ca/gems/aws-sdk-ec2/lib/aws-sdk-ec2/types.rb
  def ec2_instance(name)
    {
      private_dns_name: name,
    }
  end
end

RSpec.configure do |c|
  c.include EC2Helper
end
