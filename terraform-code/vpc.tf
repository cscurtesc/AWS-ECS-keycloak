#Create the VPC
resource "aws_vpc" "aws-vpc" {
  cidr_block = var.cidr

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

#Create the Internet Gateway
resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}

#Create the 2 public subnets, in different AZs
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.app_name}-routing-table-public"
    Environment = var.app_environment
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw.id
}

#Associate the 2 subnets created above with the public routing table, so the resources placed in here have Internet access
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
