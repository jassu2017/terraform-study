output "vpc-id" {
    description = "The vpc id"
    value = aws_vpc.my-trfm-aws-vpc.id
}

output "igw-id" {
    description = "The igw id"
    value = aws_internet_gateway.my-trfm-aws-igw.id
}     

output "pub-sub-id" {
    description = "The sub pub id"
    value = aws_subnet.my-trfm-aws-public-subnet.id
  
}

output "pvt-sub-id" {
    description = "The sub pvt id"
    value = aws_subnet.my-trfm-aws-private-subnet.id
  
}

output "sg-id" {
    description = "The sg id"
    value = aws_security_group.my-trfm-aws-sg.id
  
}

output "instance-id" {
    description = "The instance id"
    value = aws_instance.my-trfm-aws-ec2.id
  
}

output "aws_ebs_volume" {
    description = "The ebs volume"
    value = aws_ebs_volume.ec2-m-ebs-volume.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.my-trfm-aws-ec2.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${aws_instance.my-trfm-aws-ec2.key_name}.pem ubuntu@${aws_instance.my-trfm-aws-ec2.public_ip}"
}