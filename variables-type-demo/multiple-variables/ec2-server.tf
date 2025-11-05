resource "aws_instance" "ec2-instance" {
    ami = var.aws_ami
    instance_type = var.aws_instance_type
     count = 2

    //root_block_device {
    //  volume_size = var.root_block_device_size
    //  volume_type = var.root_block_device_type
    //  delete_on_termination = true
    //}

    root_block_device {
      volume_size = var.ec2_config.v_size
      volume_type = var.ec2_config.v_type
      delete_on_termination = true
    }

    tags = {
        Name = "ec2-instance${count.index}"
    }
  
}