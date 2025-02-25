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

##############################
# Auto Scaling Group Resources
##############################
resource "aws_launch_template" "wordpress_lt" {
  name_prefix            = "${var.project_name}-lt-"
  image_id               = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = base64encode(file("${path.module}/userdata.tpl"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-wordpress"
      Environment = var.env
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.wordpress_tg.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = { "Name" = "${var.project_name}-wordpress-asg", "Environment" = var.env }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "wordpress_cpu_policy" {
  name                   = "${var.project_name}-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

##############################
# RDS MySQL (Free Tier)
##############################
resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = aws_db_subnet_group.wordpress_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "${var.project_name}-wordpress-db"
  }
}

##############################
# S3 Bucket for WordPress Files
##############################
resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-wordpress-bucket"
    Environment = var.env
  }

  lifecycle {
    ignore_changes = [object_lock_configuration]
  }
}

resource "aws_s3_bucket_acl" "wordpress_bucket_acl" {
  bucket = aws_s3_bucket.wordpress_bucket.id
  acl    = "private"
}

##############################
# Security Groups
##############################
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow HTTP, HTTPS, and SSH inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

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
    Name = "${var.project_name}-ec2-sg"
  }
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "http://${aws_instance.wordpress_instance.public_dns}"
}
