resource "aws_vpc" "my-vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "sample"
  }
}

resource "aws_subnet" "my-sub1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  

  tags = {
    Name = "sample"
  }
}

resource "aws_subnet" "my-sub2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  

  tags = {
    Name = "sample"
  }
}

resource "aws_internet_gateway" "my-gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "sample"
  }
}

resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-gw.id
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
  name   = "web"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample"
  }
}


resource "aws_instance" "webserver1" {
  ami                    = var.ami-id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.my-sub1.id
  user_data              = base64encode(file("userdata.sh"))
}