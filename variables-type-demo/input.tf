variable "region" {

  description = "AWS region for s3"
  type = string
  default = "ap-south-1"
  
}

variable "aws_ami" {
  description = "value of ami id"
  type = string
  default = "ami-00bb6a80f01f03502"
}

variable "aws_instance_type" {
  description = "value of instance type"
  type = string
// added the validation
  validation {
    condition = var.aws_instance_type == "t2.micro" || var.aws_instance_type == "t2.nano"
    error_message = "The instance must be t2.micro or t2.nano"
  }
  
  
}