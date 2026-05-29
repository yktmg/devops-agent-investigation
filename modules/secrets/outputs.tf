output "secret_arn" {
  description = "ARN of the Slack webhook secret"
  value       = aws_secretsmanager_secret.slack_webhook.arn
}
