output "alb_dns_name" {
  value = data.terraform_remote_state.todo.outputs.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "sample_target_group_arn" {
  value = aws_lb_target_group.sample.arn
}