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
# Internet Gateway and NAT Gateway
##############################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "${var.project_name}-nat-gw"
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

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

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

##############################
# EC2 Instance and User Data
##############################

resource "aws_instance" "instance" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  availability_zone           = var.availability_zone_1
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.sg_vpc.id]
  # Update the IAM instance profile if needed:
  iam_instance_profile        = "your-iam-profile"
  count                       = 1

  tags = {
    Name = "${var.project_name}-instance"
  }

  user_data = base64encode(data.template_file.ec2userdatatemplate.rendered)

  provisioner "local-exec" {
    command = "echo Instance Type = ${self.instance_type}, Instance ID = ${self.id}, Public IP = ${self.public_ip}, AMI ID = ${self.ami} >> metadata"
  }
}

data "template_file" "ec2userdatatemplate" {
  template = file("userdata.tpl")
  vars = {
    bucket_name = var.s3_bucket_name
  }
}

output "ec2rendered" {
  value = data.template_file.ec2userdatatemplate.rendered
}

output "public_ip" {
  value = aws_instance.instance[0].public_ip
}

##############################
# Application Load Balancer (ALB)
##############################

resource "aws_lb_target_group" "target_group" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.dev_vpc.id

  tags = {
    Name = var.project_name
  }

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "application_lb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups    = [aws_security_group.sg_vpc.id]
  ip_address_type    = "ipv4"

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  count            = length(aws_instance.instance)
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.instance[count.index].id
}

##############################
# Security Groups
##############################

resource "aws_security_group" "sg_vpc" {
  name        = "${var.project_name}-sg-vpc"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.egress_cidr_block]
  }

  tags = {
    Name = "${var.project_name}-sg-vpc"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.project_name}-allow-ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.egress_cidr_block]
  }

  tags = {
    Name = "${var.project_name}-allow-ssh"
  }
}

resource "aws_security_group" "allow_ec2_aurora" {
  name        = "${var.project_name}-allow-ec2-aurora"
  description = "Allow EC2 to Aurora traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "Allow EC2 to Aurora"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.egress_cidr_block]
  }

  tags = {
    Name = "${var.project_name}-allow-ec2-aurora"
  }
}

resource "aws_security_group" "allow_aurora_access" {
  name        = "${var.project_name}-allow-aurora-access"
  description = "Allow Aurora access"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-allow-aurora-access"
  }
}

##############################
# S3 Bucket
##############################

resource "aws_s3_bucket" "project_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.project_name
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.project_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
