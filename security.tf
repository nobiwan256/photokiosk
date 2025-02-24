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
    to
