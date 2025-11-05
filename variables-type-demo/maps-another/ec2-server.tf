resource "aws_instance" "per_region" {
   
    ami = var.region_config[var.region].ami
    instance_type = var.region_config[var.region].instance_type
    
    tags = {
      Name = "example-${var.region}"
    }
}