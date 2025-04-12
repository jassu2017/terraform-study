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
