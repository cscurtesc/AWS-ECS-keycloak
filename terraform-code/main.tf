terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create 2 public subnets in 2 AZs
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table and route all traffic through the internet gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id
  }
}

# Associate the public subnets with the route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create an ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}

# Create a security group for the ECS tasks
resource "aws_security_group" "ecs_tasks_sg" {
  name_prefix = "ecs-tasks-sg"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a task definition for the ECS service
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task-family"
  container_definitions    = jsonencode([{
    name            = "keycloak-container"
    image           = "cscurtesc/keycloak:latest"
    portMappings    = [{
      containerPort = 8080
      hostPort      = 8080
    },
    {
      containerPort = 8443
      hostPort      = 8443
    }]
  }])
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
}

# Create an ECS service to run the task definition
resource "aws_ecs_service" "my_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1

  # Use the same security group and subnets as the task definition
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  }
}

