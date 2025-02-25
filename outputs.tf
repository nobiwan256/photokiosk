output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.dev_vpc.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.wordpress_alb.dns_name
}

output "mysql_endpoint" {
  description = "Endpoint for the MySQL database"
  value       = aws_db_instance.wordpress_db.address
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "http://${aws_lb.wordpress_alb.dns_name}"
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress_asg.name
}
