provider "aws" {
  region = var.aws_region
}

module "secrets" {
  source            = "./modules/secrets"
  slack_webhook_url = var.slack_webhook_url
}

module "notify" {
  source     = "./modules/notify"
  secret_arn = module.secrets.secret_arn
}

module "error_generator" {
  source = "./modules/error-generator"
}

module "monitoring" {
  source         = "./modules/monitoring"
  log_group_name = module.error_generator.log_group_name
}

module "investigation" {
  source         = "./modules/investigation"
  alarm_arn      = module.monitoring.alarm_arn
  agent_space_id = var.agent_space_id
}
