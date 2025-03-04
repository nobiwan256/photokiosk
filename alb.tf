resource "aws_lb_target_group" "wordpress_tg" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.dev_vpc.id

  tags = {
    Name        = "${var.project_name}-target-group"
    Environment = var.env
  }

  health_check {
    enabled             = true
    interval            = 60                  
    path                = "/health.html"      # Simpler path for health check
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10                  
    healthy_threshold   = 2
    unhealthy_threshold = 3                   
    matcher             = "200"               # Only accept HTTP 200 as healthy
  }
  
  depends_on = [aws_vpc.dev_vpc]
}

resource "aws_lb" "wordpress_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  ip_address_type    = "ipv4"

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.env
  }
  
  depends_on = [
    aws_security_group.alb_sg,
    aws_subnet.public_1,
    aws_subnet.public_2
  ]
}

resource "aws_lb_listener" "wordpress_http" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
  
  depends_on = [
    aws_lb.wordpress_alb,
    aws_lb_target_group.wordpress_tg
  ]
}
