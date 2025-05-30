resource "aws_vpc" "my-trfm-aws-vpc" {
  cidr_block       = "${var.vpc_cidr_block}"
  instance_tenancy = "default"

  tags = {
    name = "my-trfm-aws-vpc"
  }


}


resource "aws_subnet" "my-trfm-aws-public-subnet" {
  vpc_id     = aws_vpc.my-trfm-aws-vpc.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    name = "my-trfm-aws-public-subnet"
  }

}

resource "aws_subnet" "my-trfm-aws-private-subnet" {
  vpc_id     = aws_vpc.my-trfm-aws-vpc.id
  cidr_block = "12.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    name = "my-trfm-aws-private-subnet"
  }

}

resource "aws_internet_gateway" "my-trfm-aws-igw" {
  vpc_id = aws_vpc.my-trfm-aws-vpc.id

  tags = {
    name = "my-trfm-aws-igw"
  }

}




resource "aws_route_table" "my-trfm-aws-public-rt" {
  vpc_id = aws_vpc.my-trfm-aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-trfm-aws-igw.id
  }

    tags = {
    Name = "my-trfm-aws-public-rt"
  }
}

resource "aws_route_table_association" "my-trfm-aws-rt-association-pub-sub" {
  subnet_id      = aws_subnet.my-trfm-aws-public-subnet.id
  route_table_id = aws_route_table.my-trfm-aws-public-rt.id
}

resource "aws_route_table" "my-trfm-aws-private-rt" {
  vpc_id = aws_vpc.my-trfm-aws-vpc.id

    tags = {
    Name = "my-trfm-aws-private-rt"
  }
}

resource "aws_route_table_association" "my-trfm-aws-rt-association-pvt-sub" {
  subnet_id      = aws_subnet.my-trfm-aws-private-subnet.id
  route_table_id = aws_route_table.my-trfm-aws-private-rt.id
}

resource "aws_instance" "my-trfm-aws-ec2" {
    ami           = "ami-00bb6a80f01f03502"
    instance_type = "t2.medium"
    subnet_id = aws_subnet.my-trfm-aws-public-subnet.id
    associate_public_ip_address = true
    key_name = "demo-vpc-flow"
    vpc_security_group_ids = [aws_security_group.my-trfm-aws-sg.id] 
    user_data = filebase64("${path.module}/install_minikube.sh")

    tags = {
      Name = "my-trfm-ec2-k8s"
    }
}

resource "aws_security_group" "my-trfm-aws-sg" {
    name        = "my-trfm-aws-sg"
    description = "Allow web traffics"
    vpc_id      = aws_vpc.my-trfm-aws-vpc.id
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
      name = "my-trfm-aws-sg"
    }
  
}

resource "aws_key_pair" "demo-key" {
    key_name = "demo-vpc-flow"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6/K+TyLJKpZwtezGCLKIHtefJcGaavN6t5Odhs4gCvR4g4ydPxyjYhTWq/WF0iuBaC1GQPIByxLefb26gdR0UPxGzJgxQnq4oRiy2hBUSK1r0gkkxV4tuKBaIZMWCH7XNrgyf+J6Er45cRtOIibVCOquSGge9fLNxz0WV8oL3Vyn8SY4hA/4P2ZbDezVKdkTTv+KnY/w+wjIj0apaCqlJ2QwLko7IKdoCJ0pXXlx3KPAqgQ644PPNBTNRhIhmcDYehb3sVnbaHopyjJYE1mA9atgyJuvt4dtt/k0pxex+Cysu58SCOe0Qlx1YuxdNSVuzxqguYp29pNHfZ9P6SE2p"
  
}

resource "aws_ebs_volume" "ec2-m-ebs-volume" {
  availability_zone = aws_subnet.my-trfm-aws-public-subnet.availability_zone
  size              = 20

  tags = {
    Name = "my-trfm-aws-volume"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ec2-m-ebs-volume.id
  instance_id = aws_instance.my-trfm-aws-ec2.id
  force_detach =  true
}

