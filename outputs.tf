output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.dev_vpc.id
}

output "wordpress_public_ip" {
  description = "Public IP of the WordPress EC2 instance"
  value       = aws_instance.wordpress_instance.public_ip
}

output "wordpress_public_dns" {
  description = "Public DNS of the WordPress EC2 instance"
  value       = aws_instance.wordpress_instance.public_dns
}

output "mysql_endpoint" {
  description = "Endpoint for the MySQL database"
  value       = aws_db_instance.wordpress_db.address
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "http://${aws_instance.wordpress_instance.public_dns}"
}
