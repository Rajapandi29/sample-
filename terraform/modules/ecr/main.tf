resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
<<<<<<< HEAD
}
=======

  image_scanning_configuration {
    scan_on_push = true
  }
}
>>>>>>> 5ae2a26 (new)
