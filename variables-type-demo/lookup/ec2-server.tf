resource "aws_instance" "per_region" {
   
    ami = var.ami-type
    instance_type = lookup(var.instance_type, "test", "t2.micro")

  
    tags = {
      Name = "example-${var.region}"
    }
}