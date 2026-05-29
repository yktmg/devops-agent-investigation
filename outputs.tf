output "error_generator_function_name" {
  description = "Name of the error generator Lambda (for manual invoke test)"
  value       = module.error_generator.function_name
}

output "alarm_name" {
  description = "Name of the CloudWatch alarm"
  value       = module.monitoring.alarm_name
}

output "investigation_function_name" {
  description = "Name of the investigation bridge Lambda"
  value       = module.investigation.function_name
}
