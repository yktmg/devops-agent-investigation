resource "aws_secretsmanager_secret" "slack_webhook" {
  name        = var.secret_name
  description = "Slack Incoming Webhook URL for DevOps Agent notifications"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "slack_webhook" {
  secret_id     = aws_secretsmanager_secret.slack_webhook.id
  secret_string = var.slack_webhook_url
}
