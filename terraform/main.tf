module "vpc" {
  source = "s3::https://s3-${var.aws_region}.amazonaws.com/terraform-module-23-8/vpc/"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
}

module "security_group" {
  source = "s3::https://s3-${var.aws_region}.amazonaws.com/your-common-modules-bucket/modules/sg.zip"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
}

module "alb" {
  source = "s3::https://s3-${var.aws_region}.amazonaws.com/your-common-modules-bucket/modules/alb.zip"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_group.alb_sg_id
  container_port    = var.container_port
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "ecs" {
  source = "./modules/ecs"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_id  = module.security_group.ecs_sg_id
  container_image    = "${module.ecr.ecr_repository_url}:latest"
  container_port     = var.container_port
  cpu                = var.cpu
  memory             = var.memory
  desired_count      = var.desired_count
  target_group_arn   = module.alb.target_group_arn
}