module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.0.0"


  name = "single-instance"

  instance_type          = "t2.micro"
  ami = "ami-00bb6a80f01f03502"
  key_name = "mumbai-kp-25"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  #ingress = var.sample_default_security_group_ingress



  tags = {
    Terraform   = "true"
    Name = "trial-instance-module"
    Environment = "dev"
  }


}