# Launch Template
resource "aws_launch_template" "wordpress_lt" {
  name_prefix            = "${var.project_name}-lt-"
  image_id               = "ami-0735c191cf914754d"  # Updated valid Amazon Linux 2 AMI for us-west-2
  instance_type          = "t2.micro"  # Using t2.micro as requested
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  user_data = base64encode(templatefile("userdata.tpl", { 
    db_endpoint = aws_db_instance.wordpress_db.address,
    db_name     = var.rds_db_name,
    db_user     = var.rds_username,
    db_password = var.rds_password
  }))
  
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
  desired_capacity    = 1  # Fixed at 1 for persistent instance
  min_size            = 1  # Fixed at 1 for persistent instance
  max_size            = var.asg_max_size  # Allow scaling for high load if needed
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  target_group_arns   = [aws_lb_target_group.wordpress_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }
  
  # This helps prevent termination of our persistent instance during updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
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
