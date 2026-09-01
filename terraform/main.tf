data "terraform_remote_state" "todo" {
  backend = "s3"

  config = {
    bucket = "my-terraformstate-18-8"
    key    = "my-terraformstate-18-8/mug1"
    region = "us-east-1"
  }
}


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
      Sid    = "AllowPublish"
      Effect = "Allow"

      Principal = {
        Service = [
          "events.amazonaws.com",
          "cloudwatch.amazonaws.com"
        ]
      }

      Action   = "SNS:Publish"
      Resource = aws_sns_topic.alerts.arn
    }]
  })
}


# --------------------------------------------------
# SAMPLE TARGET GROUP
# --------------------------------------------------

resource "aws_lb_target_group" "sample" {
  name     = "sample-app-dev-tg"
  port     = var.container_port
  protocol = "HTTP"

  vpc_id = data.terraform_remote_state.todo.outputs.vpc_id

  target_type = "ip"

  health_check {
  path                = "/api/health"
  protocol            = "HTTP"
  port                = "traffic-port"
  healthy_threshold   = 2
  unhealthy_threshold = 3
  timeout             = 5
  interval            = 30
  matcher             = "200"
}

  tags = {
    Name = "sample-app-dev-tg"
  }
}


# --------------------------------------------------
# SAMPLE PATH ROUTING
# --------------------------------------------------

resource "aws_lb_listener_rule" "sample" {

  listener_arn = data.terraform_remote_state.todo.outputs.alb_listener_arn

  priority = 100

  condition {
    path_pattern {
      values = [
        "/sample",
        "/sample/*"
      ]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample.arn
  }
}


# --------------------------------------------------
# ECR
# --------------------------------------------------

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}


# --------------------------------------------------
# ECS
# --------------------------------------------------

module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # Use TODO app VPC
  vpc_id = data.terraform_remote_state.todo.outputs.vpc_id

  # Use TODO app private subnets
  private_subnet_ids = data.terraform_remote_state.todo.outputs.private_subnet_ids

  # Use TODO ALB security group
  alb_sg_id = data.terraform_remote_state.todo.outputs.alb_sg_id

  container_image = "${module.ecr.ecr_repository_url}:latest"

  container_port = var.container_port

  cpu           = var.cpu
  memory        = var.memory
  desired_count = var.desired_count

  # IMPORTANT:
  # Sample ECS registers into Sample Target Group
  target_group_arn = aws_lb_target_group.sample.arn

  alert_sns_topic_arn = aws_sns_topic.alerts.arn
}