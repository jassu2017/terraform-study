resource "aws_vpc" "my-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "user_mgmt_npm"
  }
}

resource "aws_subnet" "my-sub1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "ap-south-1a"
  

  tags = {
    Name = "user_mgmt_npm_public"
  }
}

resource "aws_subnet" "my-sub2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "12.0.2.0/24"
  availability_zone = "ap-south-1b"
  

  tags = {
    Name = "user_mgmt_npm_private"
  }
}

resource "aws_internet_gateway" "my-gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "user_mgmt_npm"
  }
}

resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-gw.id
  }
  tags = {
    Name = "user_mgmt_npm"
  }
}


resource "aws_route_table_association" "my-rt-a" {
  subnet_id      = aws_subnet.my-sub1.id
  route_table_id = aws_route_table.my-rt.id
}

resource "aws_route_table_association" "my-rt-b" {
  subnet_id      = aws_subnet.my-sub2.id
  route_table_id = aws_route_table.my-rt.id
}

resource "aws_security_group" "webSg" {
  name   = "web-npm"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "npm"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "user_mgmt_npm"
  }
}

resource "aws_key_pair" "demo-key" {
    key_name = "demo-vpc-flow"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6/K+TyLJKpZwtezGCLKIHtefJcGaavN6t5Odhs4gCvR4g4ydPxyjYhTWq/WF0iuBaC1GQPIByxLefb26gdR0UPxGzJgxQnq4oRiy2hBUSK1r0gkkxV4tuKBaIZMWCH7XNrgyf+J6Er45cRtOIibVCOquSGge9fLNxz0WV8oL3Vyn8SY4hA/4P2ZbDezVKdkTTv+KnY/w+wjIj0apaCqlJ2QwLko7IKdoCJ0pXXlx3KPAqgQ644PPNBTNRhIhmcDYehb3sVnbaHopyjJYE1mA9atgyJuvt4dtt/k0pxex+Cysu58SCOe0Qlx1YuxdNSVuzxqguYp29pNHfZ9P6SE2p"
  
}


resource "aws_instance" "webserver1" {
  ami                    = "ami-00bb6a80f01f03502"
  instance_type          = "t2.micro"
  associate_public_ip_address = true
  key_name = "demo-vpc-flow"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.my-sub1.id
  tags = {
    Name = "user_mgmt_npm"
  }
}
