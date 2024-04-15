variable "sns_topic_name" {
    type = string
    default = "alarm_cloudwatch_forwarder"
}

variable "alarm_name" {
    type = string
    default = "alarm_cloudwatch_cpu_usage"
}

variable "cloudwatch_metric_operator" {
    type = string
    default = "GreaterThanThreshold"
}

variable "cloudwatch_metric_evaluation_periods" {
    type = number
    default = 1
}

variable "cloudwatch_metric_name" {
    type = string
    default = "CPUUtilization"
}

variable "cloudwatch_metric_namespace" {
    type = string
    default = "AWS/EC2"
}

variable "cloudwatch_metric_period" {
    type = number
    default = 60
}

variable "cloudwatch_metric_threshold" {
    type = number
    default = 30
}

variable "cloudwatch_metric_description" {
    type = string
    default = "This metric monitors EC2 CPU utilization"
}

variable "cloudwatch_metric_dimension_name" {
    type = string
    default = "InstanceId"
}

variable "cloudwatch_metric_dimension_value" {
    type = string
    default = "i-0123456789abcdefg"
}

variable "lambda_name" {
    type = string
    default = "ms_connector"
}

variable "lambda_handler_name" {
    type = string
    default = "lambda_function.lambda_handler"
}

variable "lambda_memory_size" {
    type = number
    default = 128
}

variable "lambda_runtime" {
    type = string
    default = "python3.9"
}

variable "lambda_timeout" {
    type = string
    default = "60"
}


variable "ms_teams_webhook_url" {
    type = string
    default = "https://smtsoftwareservices.webhook.office.com/webhookb2/5ae29484-dbde-41a5-88e0-905311562b39@00a83132-4221-4698-a787-6d679d557a90/IncomingWebhook/7dfcd3ef61344307bb37c91dff78e760/8ffb8c33-dc6a-4d52-b7df-0f622e6ddd2c"
}

