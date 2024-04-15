output "jenkins_sg_id" {
    description = "Id for the jenkins sg"
    value = aws_security_group.jenkins-sg.id
}
