module "vpc" {
  source = "s3://terraform-module-23-8/vpc/"


  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs

  private_subnet_cidrs = var.private_subnet_cidrs
}

# Central alerting topic — both the ALB "app down" alarm and the ECS
# "task stopped" event send their notifications here.
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_subscription" "sms_alert" {
  count     = var.alert_phone != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sms"
  endpoint  = var.alert_phone
}

resource "aws_sns_topic_policy" "allow_cloudwatch_eventbridge_publish" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowPublish"
      Effect    = "Allow"
      Principal = { Service = ["events.amazonaws.com", "cloudwatch.amazonaws.com"] }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.alerts.arn
    }]
  })
}

module "alb" {
  source = "s3://terraform-module-23-8/alb/"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  container_port       = var.container_port
  alert_sns_topic_arn  = aws_sns_topic.alerts.arn
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "ecs" {
  source = "./modules/ecs"


  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  alb_sg_id            = module.alb.alb_sg_id
  container_image      = "${module.ecr.ecr_repository_url}:latest"
  container_port       = var.container_port
  cpu                  = var.cpu
  memory               = var.memory
  desired_count        = var.desired_count
  target_group_arn     = module.alb.target_group_arn
  alert_sns_topic_arn  = aws_sns_topic.alerts.arn
}

