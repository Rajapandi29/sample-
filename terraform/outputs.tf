output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
<<<<<<< HEAD
}
=======
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
>>>>>>> 5ae2a26 (new)
