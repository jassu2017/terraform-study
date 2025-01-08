output "ec2-public-ip-server-1" {
    value = aws_instance.webserver1.public_dns

  
}

output "ec2-public-ip-server-2" {
    value = aws_instance.webserver2.public_dns

  
}

output "lb-name" {
    value = aws_lb.myalb.dns_name
}