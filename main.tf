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

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = element([var.public_subnet_cidr_1, var.public_subnet_cidr_2], count.index)
  availability_zone       = element([var.availability_zone_1, var.availability_zone_2], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = element([var.private_subnet_cidr_1, var.private_subnet_cidr_2], count.index)
  availability_zone       = element([var.availability_zone_1, var.availability_zone_2], count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
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

resource "aws_route_table_association" "public_assoc" {
  count          = 2
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = element(aws_subnet.public[*].id, count.index)
}
