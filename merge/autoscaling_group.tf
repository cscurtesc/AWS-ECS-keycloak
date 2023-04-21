#Create the autoscaling group
resource "aws_autoscaling_group" "default" {
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.default.name
  max_size             = 3
  min_size             = 1
  name                 = "auto-scaling-group"

  tag {
    key                 = "Env"
    propagate_at_launch = true
    value               = "production"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "Containers"
  }

  target_group_arns    = [aws_alb_target_group.default.arn]
  termination_policies = ["OldestInstance"]

  vpc_zone_identifier = aws_subnet.public.*.id
}

#Define the autoscaling launch configuration
resource "aws_launch_configuration" "default" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  image_id                    = "ami-076214eda80ae72ef"
  instance_type               = "t2.micro"
  key_name                    = "ed-noua"

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "lauch-configuration-"

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  security_groups = [aws_security_group.ec2.id]
  user_data       = "#!/bin/bash\necho ECS_CLUSTER=production >> /etc/ecs/ecs.config"
}

#Define the EC2 Instance profile role
resource "aws_iam_instance_profile" "ecs" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs.name
}

#Attach a security group to the EC2 instance, accepting inbound traffic only from the LB's security group
resource "aws_security_group" "ec2" {
  description = "security-group--ec2"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    from_port       = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    to_port         = 65535
  }

       ingress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

  name = "security-group--ec2"

  tags = {
    Env  = "production"
    Name = "security-group--ec2"
  }

  vpc_id = aws_vpc.aws-vpc.id
}
