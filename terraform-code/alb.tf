#Create the Load balancer, associate it with the 2 public subnets
resource "aws_alb" "alb" {
  name            = "${var.app_name}-${var.app_environment}-alb"
  security_groups = [aws_security_group.alb-sc.id]
  subnets         = aws_subnet.public.*.id
 
  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

#Create the ALB's security group
resource "aws_security_group" "alb-sc" {
  description = "security-group--alb"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  name = "security-group--alb"

  tags = {
    Name        = "${var.app_name}-sg"
    Environment = var.app_environment
  }

  vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }
}

#We also need to create a Load Balancer Target Group, it will relate the Load Balancer with the Containers.
#One very important thing here is the attribute path within health_check. This is a route on the application that the Load Balancer will use to check the status of the application.

resource "aws_alb_target_group" "target_group" {
  name        = "${var.app_name}-${var.app_environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws-vpc.id

  health_check {
    path = "/"
  }

  stickiness {
    type = "lb_cookie"
  }
  
   tags = {
    Name        = "${var.app_name}-lb-tg"
    Environment = var.app_environment
  }

}

