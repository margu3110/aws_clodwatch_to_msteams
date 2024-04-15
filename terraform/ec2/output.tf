output "ec2_private_ip" {
    description = "Private IP"
    value = aws_instance.ec2.private_ip
}

output "ec2_public_ip" {
    description = "Public IP"
    value = aws_instance.ec2.public_ip
}
