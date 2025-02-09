resource "aws_vpc" "demo-flow-log-vpc" {
  cidr_block       = "${var.vpc_cidr_block}"
  instance_tenancy = "default"

  tags = {
    name = "demo-flow-log-vpc"
  }


}


resource "aws_subnet" "demo-flow-log-public-subnet" {
  vpc_id     = aws_vpc.demo-flow-log-vpc.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    name = "demo-flow-log-public-subnet"
  }

}

resource "aws_subnet" "demo-flow-log-private-subnet" {
  vpc_id     = aws_vpc.demo-flow-log-vpc.id
  cidr_block = "12.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    name = "demo-flow-log-private-subnet"
  }

}

resource "aws_internet_gateway" "demo-flow-log-igw" {
  vpc_id = aws_vpc.demo-flow-log-vpc.id

  tags = {
    name = "demo-flow-log-igw"
  }

}


# resource "aws_internet_gateway_attachment" "demo-flow-log-igw-attach" {
#   internet_gateway_id = aws_internet_gateway.demo-flow-log-igw.id
#   vpc_id              = aws_vpc.demo-flow-log-vpc.id
# }

resource "aws_route_table" "demo-flow-log-public-rt" {
  vpc_id = aws_vpc.demo-flow-log-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-flow-log-igw.id
  }

    tags = {
    Name = "demo-flow-log-public-rt"
  }
}

resource "aws_route_table_association" "demo-flow-log-rt-association-pub-sub" {
  subnet_id      = aws_subnet.demo-flow-log-public-subnet.id
  route_table_id = aws_route_table.demo-flow-log-public-rt.id
}

resource "aws_route_table" "demo-flow-log-private-rt" {
  vpc_id = aws_vpc.demo-flow-log-vpc.id

    tags = {
    Name = "demo-flow-log-private-rt"
  }
}

resource "aws_route_table_association" "demo-flow-log-rt-association-pvt-sub" {
  subnet_id      = aws_subnet.demo-flow-log-private-subnet.id
  route_table_id = aws_route_table.demo-flow-log-private-rt.id
}

resource "aws_instance" "demo-flow-log-ec2" {
    ami           = "ami-00bb6a80f01f03502"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.demo-flow-log-public-subnet.id
    associate_public_ip_address = true
    key_name = "demo-vpc-flow"
    vpc_security_group_ids = [aws_security_group.demo-flow-log-sg.id] 
}

resource "aws_security_group" "demo-flow-log-sg" {
    name        = "demo-flow-log-sg"
    description = "Allow web traffics"
    vpc_id      = aws_vpc.demo-flow-log-vpc.id
    egress = [ 
        {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
     ]
     ingress = [
    {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]  
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
         
    {
      description      = "ICMP"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]  
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
        }

       
     ]

    tags = {
      name = "demo-flow-log-sg"
    }
  
}

resource "aws_key_pair" "demo-key" {
    key_name = "demo-vpc-flow"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6/K+TyLJKpZwtezGCLKIHtefJcGaavN6t5Odhs4gCvR4g4ydPxyjYhTWq/WF0iuBaC1GQPIByxLefb26gdR0UPxGzJgxQnq4oRiy2hBUSK1r0gkkxV4tuKBaIZMWCH7XNrgyf+J6Er45cRtOIibVCOquSGge9fLNxz0WV8oL3Vyn8SY4hA/4P2ZbDezVKdkTTv+KnY/w+wjIj0apaCqlJ2QwLko7IKdoCJ0pXXlx3KPAqgQ644PPNBTNRhIhmcDYehb3sVnbaHopyjJYE1mA9atgyJuvt4dtt/k0pxex+Cysu58SCOe0Qlx1YuxdNSVuzxqguYp29pNHfZ9P6SE2p"
  
}
