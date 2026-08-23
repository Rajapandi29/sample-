output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name

}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

