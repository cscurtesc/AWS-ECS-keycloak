resource "aws_alb" "default" {
  name            = "alb"
  security_groups = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public__a.id,
    aws_subnet.public__b.id
  ]
}

resource "aws_security_group" "alb" {
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
    Env  = "production"
    Name = "security-group--alb"
  }

  vpc_id = aws_vpc.default.id
}

resource "aws_alb_listener" "default" {
  default_action {
    target_group_arn = aws_alb_target_group.default.arn
    type             = "forward"
  }

  load_balancer_arn = aws_alb.default.arn
  port              = 80
  protocol          = "HTTP"
}
resource "aws_alb_target_group" "default" {
  health_check {
    path = "/"
  }

  name     = "alb-target-group"
  port     = 8080
  protocol = "HTTP"

  stickiness {
    type = "lb_cookie"
  }

  vpc_id = aws_vpc.default.id
}
