variable "secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
  default     = "devops-agent/slack-webhook-url"
}

variable "slack_webhook_url" {
  description = "Slack Incoming Webhook URL"
  type        = string
  sensitive   = true
}
