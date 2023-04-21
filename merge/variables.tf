
variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnets" {
  description        = "List of public subnets"
}

variable "availability_zones" {
  description        = "List of availability zones"
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
}
