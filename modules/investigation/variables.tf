variable "alarm_arn" {
  description = "ARN of the CloudWatch Alarm to monitor"
  type        = string
}

variable "agent_space_id" {
  description = "ID of the DevOps Agent Space to invoke"
  type        = string
}
