variable "athena_database" {}

variable "bucket_name" {}

variable "alarm_email" {}

variable "region" {}

variable "aws_co_cron" {
  default = "cron(16 1 * ? * *)"
}

# cloudwatch metric alarm 
variable "cloudwatch_metric_alarm_statistic" {
  default = "Minimum"
}

# 1 error
variable "cloudwatch_metric_alarm_threshold" {
  default = "1"
}

# 3 hours in secs
variable "cloudwatch_metric_alarm_period" {
  default = "10800"
}

variable "cloudwatch_metric_alarm_comparison_operator" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "cloudwatch_metric_alarm_metric_name" {
  default = "Errors"
}

variable "cloudwatch_metric_alarm_evaulation_periods" {
  default = "1"
}

# environment
variable "env" {
  default = ""
}

variable "first_of_the_month_cron" {
  default = "cron(16 1 * ? * *)"
}
variable "enable_cloudwatch_event" {
  default = false
}

variable "specific_accounts" {
  type    = string
  default = ""
}

variable "enable_accounts_collector" {
  default = true
}