resource "aws_instance" "wordpress_instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"  # Free tier eligible
  availability_zone           = var.availability_zone_1
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  user_data                   = templatefile("userdata.tpl", { db_endpoint = aws_db_instance.wordpress_db.address })

  tags = {
    Name = "${var.project_name}-wordpress"
  }
}
