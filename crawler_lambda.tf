#Athena createion Lambda

data "archive_file" "start_crawler" {
  type        = "zip"
  source_file = "${path.module}/source/start_crawler.py"
  output_path = "${path.module}/output/start_crawler.zip"
}

resource "aws_lambda_function" "start_crawler" {
  filename         = "${path.module}/output/start_crawler.zip"
  function_name    = "start_crawler${var.env}"
  role             = aws_iam_role.iam_role_for_accounts.arn
  handler          = "start_crawler.lambda_handler"
  source_code_hash = data.archive_file.start_crawler.output_base64sha256
  runtime          = "python3.6"
  memory_size      = "512"
  timeout          = "150"
  description      = "gathers org data and places in sqs"

  environment {
    variables = {
      EC2_CRAWLER    = aws_glue_crawler.ec2_compute_optimizer.id
      AUTO_CRAWLER   = aws_glue_crawler.auto_compute_optimizer.id
      EBS_CRAWLER    = aws_glue_crawler.ebs_volumes_optimizer.id
      LAMBDA_CRAWLER = aws_glue_crawler.lambda_optimizer.id

    }
  }

  tags = {
    "Team" = "FinOps"
  }
}

resource "aws_lambda_permission" "allow_s3_start_crawler" {
  statement_id   = "AllowExecutionFroms3"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.start_crawler.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}"
  source_account = data.aws_caller_identity.current.account_id

  depends_on = [aws_lambda_function.start_crawler]
}

# resource "aws_cloudwatch_event_rule" "start_crawler_cloudwatch_rule" {
#   name                = "${aws_lambda_function.start_crawler.function_name}_trigger"
#   schedule_expression = var.first_of_the_month_cron
# }

# resource "aws_cloudwatch_event_target" "start_crawler_lambda" {
#   rule      = aws_cloudwatch_event_rule.start_crawler_cloudwatch_rule.name
#   target_id = "${aws_lambda_function.start_crawler.function_name}_target"
#   arn       = aws_lambda_function.start_crawler.arn
# }

resource "aws_cloudwatch_metric_alarm" "account_crawler_lambda_function_error_alarm" {
  alarm_name                = "${aws_lambda_function.start_crawler.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${aws_lambda_function.start_crawler.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.start_crawler.function_name
  }
  # alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

