##############################
# VPC and Subnets
##############################

resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = var.project_name
    Environment = var.env
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.public_subnet_cidr_1
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-1"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.private_subnet_cidr_1
  availability_zone = var.availability_zone_1

  tags = {
    Name = "${var.project_name}-private-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-2"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = var.availability_zone_2

  tags = {
    Name = "${var.project_name}-private-2"
  }
}

##############################
# Internet Gateway
##############################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

##############################
# Route Tables and Associations
##############################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Private subnets will not have outbound Internet access (no NAT gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "public_1_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_route_table_association" "public_2_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_2.id
}

resource "aws_route_table_association" "private_1_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_1.id
}

resource "aws_route_table_association" "private_2_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_2.id
}
