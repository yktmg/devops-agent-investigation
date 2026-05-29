output "function_name" {
  description = "Name of the error generator Lambda"
  value       = aws_lambda_function.error_generator.function_name
}

output "log_group_name" {
  description = "Log group name of the error generator Lambda"
  value       = aws_cloudwatch_log_group.error_generator.name
}
