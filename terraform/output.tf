output "sns_topic_arn" {
  value = aws_sns_topic.cloudwatch_alarm_topic.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.sns_to_teams.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.sns_to_teams.arn
}


output "cloudwatch_metric_alarm" {
  value = aws_cloudwatch_metric_alarm.alarm.arn
}