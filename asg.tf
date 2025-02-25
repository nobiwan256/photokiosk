##############################
# Auto Scaling Group Resources
##############################

# Launch Template
resource "aws_launch_template" "wordpress_lt" {
  name_prefix            = "${var.project_name}-lt-"
  image_id               = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  user_data = base64encode(templatefile("userdata.tpl", { db_endpoint = aws_db_instance.wordpress_db.address }))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-wordpress"
      Environment = var.env
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
  
  depends_on = [
    aws_security_group.ec2_sg,
    aws_db_instance.wordpress_db
  ]
}

# Auto Scaling Group
resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  target_group_arns   = [aws_lb_target_group.wordpress_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "${var.project_name}-wordpress-asg"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
  
  lifecycle {
    create_before_destroy = true
  }
  
  depends_on = [
    aws_launch_template.wordpress_lt,
    aws_lb_target_group.wordpress_tg,
    aws_subnet.public_1,
    aws_subnet.public_2
  ]
}

# Auto Scaling Policy - CPU Based Scaling
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
  
  depends_on = [aws_autoscaling_group.wordpress_asg]
}
