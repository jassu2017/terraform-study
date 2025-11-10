
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"



name = "my-vpc"
cidr = "10.0.0.0/16"

azs             = ["ap-south-1a"]
private_subnets = ["10.0.1.0/24"]
public_subnets  = ["10.0.101.0/24"]





tags = {
    Terraform = true
    Environment = "dev"
}


}

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name = "module-sample-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [ "ssh-tcp" ]
  egress_rules = [ "all-all" ]

  
}