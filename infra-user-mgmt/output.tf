output "ec2-public-ip-server-1" {
    value = aws_instance.webserver1.public_dns

  
}
