locals {
    jenkins_ports = [8080,22]
}


### Create jenkins Group
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins security group"
  description = "Allow access to ports 8080 and 22"
  vpc_id      = var.vpc_id

   dynamic "ingress" {
    for_each = local.jenkins_ports
    content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
    appName = var.appName
  }
}
