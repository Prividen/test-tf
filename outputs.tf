output "account_id" {
  description = "AWS account ID"
  value = data.aws_caller_identity.current.account_id
}

output "caller_user" {
  description = "Current user ID"
  value = data.aws_caller_identity.current.user_id
}

output "aws_region" {
  description = "Current AWS region"
  value = data.aws_region.current.name
}

output "instance_t1_private_ip" {
  description = "Private IP address of the EC2 instance"
  value = aws_instance.test1.*.private_ip
}

output "instance_t1_public_ip" {
  description = "Public IP address of the EC2 instance"
  value = aws_instance.test1.*.public_ip
}

output "instance_t1_subnet_id" {
  description = "Subnet ID of the EC2 instance"
  value = aws_instance.test1.*.subnet_id
}

output "instance_t2_public_ip" {
  value = {
    for k, v in aws_instance.test2 : k => v.public_ip
  }
}

