output "instance_public_ip" {
  value = aws_instance.instance[0].public_ip
}

output "alb_dns_name" {
  value = aws_lb.application_lb.dns_name
}
