variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "12.0.0.0/16"
}

variable "region" {
  description = "AWS region for vpc flow log"
  type = string
  default = "ap-south-1"
}

