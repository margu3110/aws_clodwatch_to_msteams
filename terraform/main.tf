# Define a local variable for the Lambda function zip file
locals {
  teams_lambda_zip_file = "sns_to_teams.zip"
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "src/lambda_function.py" 
  output_path = "sns_to_teams.zip"
}

# Terraform module Block to create the iam instance profile
module "iam_instance_profile" {
  source        = "./iam"
  instance_profile_name = "instance-profile-devops"
  iam_policy_name = "devops-policy"
  role_name = "role_name"
}

# Create an SNS topic for CloudWatch alarms
resource "aws_sns_topic" "cloudwatch_alarm_topic" {
  name = var.sns_topic_name
}


# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_execution" {
  name = "lambda_execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Define an IAM policy document for the Lambda function execution policy
data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.cloudwatch_alarm_topic.arn]
  }
}

# Define an IAM policy document for the SNS topic policy
data "aws_iam_policy_document" "cloudwatch_alarm_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.cloudwatch_alarm_topic.arn]
  }
}

# Create an IAM policy for the Lambda function execution
resource "aws_iam_role_policy" "lambda_execution_policy" {
  name    = "lambda_execution_policy"
  policy  = data.aws_iam_policy_document.lambda_execution_policy.json
  role    = aws_iam_role.lambda_execution.id
  # Depend on the IAM role
  depends_on = [
    aws_iam_role.lambda_execution,
  ]
}


# Create a CloudWatch metric alarm for CPU utilization
resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name          = var.alarm_name
  comparison_operator = var.cloudwatch_metric_operator
  evaluation_periods  = var.cloudwatch_metric_evaluation_periods
  metric_name         = var.cloudwatch_metric_name
  namespace           = var.cloudwatch_metric_namespace
  period              = var.cloudwatch_metric_period
  statistic           = "Average"
  threshold           = var.cloudwatch_metric_threshold
  alarm_description   = var.cloudwatch_metric_description
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_topic.arn]
  dimensions          = {
    "${var.cloudwatch_metric_dimension_name}" = var.cloudwatch_metric_dimension_value
  }
}

resource "aws_lambda_function" "sns_to_teams" {
  filename      = "sns_to_teams.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_execution.arn
  handler       = var.lambda_handler_name
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  # Set environment variables for the Lambda function
  environment {
    variables = {
      MS_TEAMS_WEBHOOK_URL = var.ms_teams_webhook_url
    }
  }

  # Depend on the SNS topic and Lambda execution policy
  depends_on = [
    aws_sns_topic.cloudwatch_alarm_topic,
    module.iam_instance_profile.aws_lambda_iam_role,
  ]
}

#Create security group for EC2 server with Jenkins
### Security Group Module
module "jenkins_sg" {
    source = "./sg"
    appName = "jenkins"
    vpc_id = data.aws_vpc.default_vpc.id
}

# Terraform module Block to create EC2 Jenkins Server
module "ec2" {
  source        = "./ec2"
  ec2_name      = "jenkins"
  key_name      = "isildur"
  ami           = "ami-0e1d30f2c40c4c701"
  instance_type = "t2.micro"
  vpc_sg        = module.jenkins_sg.jenkins_sg_id
  instance_profile = module.iam_instance_profile.instance_profile
}

# Create an SNS topic subscription for CloudWatch alarms
resource "aws_sns_topic_subscription" "teams_notifications_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_to_teams.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_to_teams.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch_alarm_topic.arn
}


data "aws_caller_identity" "current" {}