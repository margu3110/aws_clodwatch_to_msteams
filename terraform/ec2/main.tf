resource "aws_instance" "ec2" {
    ami                     = var.ami
    instance_type           = var.instance_type
    key_name                = var.key_name
    vpc_security_group_ids  = [var.vpc_sg]
    user_data               = file("ec2/install_jenkins.sh")

    iam_instance_profile    = var.instance_profile

    tags = {
        Name = var.ec2_name
    }
}