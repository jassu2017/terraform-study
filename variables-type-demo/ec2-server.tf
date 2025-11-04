resource "aws_instance" "ec2-instance" {
    ami = var.aws_ami
    instance_type = var.aws_instance_type
  
}