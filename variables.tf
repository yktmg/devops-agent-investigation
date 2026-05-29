variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "agent_space_id" {
  description = "ID of the DevOps Agent Space to invoke"
  type        = string
}
