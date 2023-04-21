resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.app_name}-task"
  container_definitions    = jsonencode([{
    name            = "${var.app_name}-${var.app_environment}-container"
    image           = "cscurtesc/keycloak:latest"
    essential       = true
    command         = ["start-dev"]
    cpu             = 256
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
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }
}


resource "aws_ecs_service" "aws-ecs-service" {
  name                    = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster                 = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition         = aws_ecs_task_definition.aws-ecs-task.arn
  scheduling_strategy     = "REPLICA"
  desired_count           = 1
  force_new_deployment    = true
 
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.listener]
}



