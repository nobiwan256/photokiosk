##############################
# Locals
##############################
locals {
  raw_userdata = templatefile("${path.module}/userdata.tpl", {
    wordpress_rds_endpoint = var.wordpress_rds_endpoint
  })
  wordpress_userdata = regexreplace(local.raw_userdata, "%\\{REQUEST_FILENAME\\}", "%%{REQUEST_FILENAME}")
}

##############################
# EC2 Instance
##############################
resource "aws_instance" "instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  availability_zone           = var.availability_zone_1
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.sg_vpc.id]
  count                       = 1

  tags = {
    Name = "${var.project_name}-instance"
  }

  user_data = base64encode(local.wordpress_userdata)

  provisioner "local-exec" {
    command = "echo Instance Type = ${self.instance_type}, Instance ID = ${self.id}, Public IP = ${self.public_ip}, AMI ID = ${self.ami} >> metadata"
  }
}

##############################
# ALB & Target Group (Fixed)
##############################
resource "aws_lb_target_group" "target_group" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.dev_vpc.id

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

  tags = {
    Name = "${var.project_name}-tg"
  }
} # ✅ Closing brace added here

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
} # ✅ Closing brace added here
