output "aws_lambda_iam_role" {
    description = "aws_iam_role"
    value = aws_iam_role.iam_role.id
}

output "instance_profile" {
    description = "Id for the jenkins sg"
    value = aws_iam_instance_profile.iam_instance_profile.id
}
