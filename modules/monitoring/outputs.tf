output "alarm_name" {
  description = "Name of the error alarm"
  value       = aws_cloudwatch_metric_alarm.error_alarm.alarm_name
}

output "alarm_arn" {
  description = "ARN of the error alarm"
  value       = aws_cloudwatch_metric_alarm.error_alarm.arn
}
