//output "ec2_id" {
//    description = "The bucket id"
//    value = aws_instance.ec2-instance.id
//}

output "dev_instance" {
    value = lookup(var.instance_type, "dev", "t2.nano")
}

output "test_instance" {
    value = lookup(var.instance_type, "test", "t2.nano")
}

