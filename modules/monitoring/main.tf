# ログから "ERROR" を含む行を拾ってメトリクス化
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "devops-agent-error-filter"
  log_group_name = var.log_group_name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "DevOpsAgent/ErrorGenerator"
    value     = "1"
    default_value = "0"
  }
}

# メトリクスを監視してアラーム発火
resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "devops-agent-error-alarm"
  alarm_description   = "Fires when error-generator outputs ERROR logs"

  namespace           = "DevOpsAgent/ErrorGenerator"
  metric_name         = "ErrorCount"
  statistic           = "Sum"

  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data  = "notBreaching"
}
