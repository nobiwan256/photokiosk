##############################
# EC2 Instance
##############################

resource "aws_instance" "wordpress_instance" {
  ami                    = var.ami_id  # Make sure var.ami_id doesn't have brackets in the variable definition
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name
  user_data              = base64encode(templatefile("userdata.tpl", { db_endpoint = aws_db_instance.wordpress_db.address }))

  tags = {
    Name        = "${var.project_name}-wordpress"
    Environment = var.env
  }

  depends_on = [
    aws_db_instance.wordpress_db
  ]
}

output "wordpress_instance_public_ip" {
  description = "Public IP address of the WordPress instance"
  value       = aws_instance.wordpress_instance.public_ip
}
