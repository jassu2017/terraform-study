variable "region" {

  description = "AWS region for ec2"
  type = string
  default = "ap-south-1"
  
}

variable "instance_type" {
  type = map(string)
  default = {
    "dev" = "t2.micro"
    "prod" = "t2.large"
  }

}

variable "ami-type" {
    type = string
    default = "ami-00bb6a80f01f03502"
    }