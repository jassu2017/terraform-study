output "vpc-id" {
    description = "The vpc id"
    value = aws_vpc.demo-flow-log-vpc.id
}

output "igw-id" {
    description = "The igw id"
    value = aws_internet_gateway.demo-flow-log-igw.id
}     

output "pub-sub-id" {
    description = "The sub pub id"
    value = aws_subnet.demo-flow-log-public-subnet.id
  
}

output "pvt-sub-id" {
    description = "The sub pvt id"
    value = aws_subnet.demo-flow-log-private-subnet.id
  
}

output "sg-id" {
    description = "The sg id"
    value = aws_security_group.demo-flow-log-sg.id
  
}

output "instance-id" {
    description = "The instance id"
    value = aws_instance.demo-flow-log-ec2.id
  
}