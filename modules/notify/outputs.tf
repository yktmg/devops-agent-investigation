output "lambda_function_name" {
  description = "Name of the notify Lambda function"
  value       = aws_lambda_function.notify.function_name
}

output "lambda_function_arn" {
  description = "ARN of the notify Lambda function"
  value       = aws_lambda_function.notify.arn
}
