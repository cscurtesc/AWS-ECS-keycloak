resource "aws_ecs_task_definition" "default" {
  family                   = "default"
  container_definitions    = jsonencode([{
    name            = "keycloak"
    image           = "cscurtesc/keycloak:latest"
    essential       = true
    command         = ["start-dev"]
    cpu             = 1
    memory          = 512
    environment     = [
                {
                    "name": "KEYCLOAK_ADMIN",
                    "value": "admin"
                },
                {
                    "name": "KEYCLOAK_ADMIN_PASSWORD",
                    "value": "change_me"
                }]
    portMappings    = [
        {
          containerPort    : 8080,
          hostPort         : 8080
        }
      ]
  }])
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
}


resource "aws_ecs_service" "default" {
  cluster                 = aws_ecs_cluster.production.id
  depends_on              = [aws_iam_role_policy_attachment.ecs]
  desired_count           = 1
  enable_ecs_managed_tags = true
  force_new_deployment    = true

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = "keycloak"
    container_port   = 8080
  }

  name            = "keycloak"
  task_definition = aws_ecs_task_definition.default.arn
}
