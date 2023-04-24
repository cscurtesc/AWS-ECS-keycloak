#Create the autoscaling group
resource "aws_autoscaling_group" "aws_autoscaling_group" {
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.default.name
  max_size             = 3
  min_size             = 1
  name                 = "auto-scaling-group"

  tag {
    key                 = "Env"
    propagate_at_launch = true
    value               = "${var.app_environment}"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "Containers"
  }

#  target_group_arns    = [aws_lb_target_group.target_group.arn]
  termination_policies = ["OldestInstance"]

  vpc_zone_identifier = aws_subnet.public.*.id
}

#Define the autoscaling launch configuration
resource "aws_launch_configuration" "default" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
#  image_id                    = "ami-076214eda80ae72ef"
  image_id 		      = "ami-0ecb3533d79bc3fdb"
  instance_type               = "m5.large"
  key_name                    = "ed-noua"

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "lauch-configuration-"

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  security_groups = [aws_security_group.service_security_group.id]
  user_data       = <<-EOT
                        #!/bin/bash
                        echo ECS_CLUSTER=${var.app_name}-${var.app_environment}-cluster >> /etc/ecs/ecs.config
                      EOT

#   user_data       = "#!/bin/bash\necho ECS_CLUSTER=production >> /etc/ecs/ecs.config"
}

#Define the EC2 Instance profile role
resource "aws_iam_instance_profile" "ecs" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecsTaskExecutionRole.name
}

#Attach a security group to the EC2 instance, accepting inbound traffic only from the LB's security group

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.aws-vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

       ingress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.app_environment
  }
}
