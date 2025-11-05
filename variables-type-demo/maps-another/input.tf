variable "region" {

  description = "AWS region for ec2"
  type = string
  default = "us-east-1"
  
}

variable "region_config" {
  type = map(object({
    ami = string
    instance_type = string 
  }))

  default = {
    "us-east-1" = {

      ami = "ami-0c55b159cbfafe1f0"
      instance_type = "t2.micro"
      
    }
    "us-west-1" = {

      ami = "ami-0bdb828fd58c52235"
      instance_type = "t2.micro"

    }

    "ap-south-1" = {

      ami = "ami-00bb6a80f01f03502"
      instance_type = "t2.nano"

    }
  }
}

 
  
