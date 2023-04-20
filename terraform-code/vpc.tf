#Create the VPC
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Env  = "production"
    Name = "vpc"
  }
}

#Create the Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Env  = "production"
    Name = "internet-gateway"
  }
}

#Create the public routing table and associate it with the IG
resource "aws_main_route_table_association" "default" {
  route_table_id = aws_route_table.public.id
  vpc_id         = aws_vpc.default.id
}

resource "aws_route_table" "public" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Env  = "production"
    Name = "route-table-public"
  }

  vpc_id = aws_vpc.default.id
}

#Create 2 subnets in 2 different Availability Zones
resource "aws_subnet" "public__a" {
  availability_zone       = "us-east-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Env  = "production"
    Name = "public-us-east-2a-blog"
  }

  vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "public__b" {
  availability_zone       = "us-east-2b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Env  = "production"
    Name = "public-us-east-2b-blog"
  }

  vpc_id = aws_vpc.default.id
}


#Associate the 2 subnets created above with the public routing table, so the resources placed in here have Internet access
resource "aws_route_table_association" "public__a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public__a.id
}

resource "aws_route_table_association" "public__b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public__b.id
}
