resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.app_name}-${var.app_environment}-cluster"
  tags = {
    Name        = "${var.app_name}-ecs"
    Environment = var.app_environment
  }
  lifecycle {
    create_before_destroy = true
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}
