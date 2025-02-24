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
    description = "Allow all outbound"
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
    description = "Allow all outbound"
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
    description = "Allow Aurora outbound"
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
    description = "Allow all inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-allow-aurora-access"
  }
}
