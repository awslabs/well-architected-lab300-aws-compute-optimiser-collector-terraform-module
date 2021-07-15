resource "aws_cloudwatch_event_rule" "finops" {
  count               = var.enable_cloudwatch_event ? 1 : 0
  name                = "Account_List"
  schedule_expression = var.aws_co_cron
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  count     = var.enable_cloudwatch_event ? 1 : 0
  target_id = "Account_List"
  rule      = aws_cloudwatch_event_rule.finops[count.index].name
  arn       = module.lambda_compute_optimiser.function_arn

  input = var.specific_accounts 
}


resource "aws_lambda_permission" "allow_cloudwatch_account_event" {
  count         = var.enable_cloudwatch_event ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatchEvent"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_compute_optimiser.function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.finops[count.index].arn

  depends_on = [module.lambda_compute_optimiser]
}

resource "aws_cloudwatch_metric_alarm" "account_event_lambda_function_error_alarm" {
  count                     = var.enable_cloudwatch_event ? 1 : 0
  alarm_name                = "${module.lambda_compute_optimiser.function_arn}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.lambda_compute_optimiser.function_arn} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_compute_optimiser.function_name
  }
  # alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}