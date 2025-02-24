##############################
# EC2 Instance and User Data
##############################

locals {
  wordpress_userdata = templatefile("${path.module}/userdata.tpl", {
    wordpress_rds_endpoint = var.wordpress_rds_endpoint
  })
}

resource "aws_instance" "instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  availability_zone           = var.availability_zone_1
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.sg_vpc.id]
  # Update the IAM instance profile if needed:
  iam_instance_profile        = "your-iam-profile"
  count                       = 1

  tags = {
    Name = "${var.project_name}-instance"
  }

  user_data = base64encode(local.wordpress_userdata)

  provisioner "local-exec" {
    command = "echo Instance Type = ${self.instance_type}, Instance ID = ${self.id}, Public IP = ${self.public_ip}, AMI ID = ${self.ami} >> metadata"
  }
}

output "instance_public_ip" {
  value = aws_instance.instance[0].public_ip
}

output "ec2_rendered_user_data" {
  value = local.wordpress_userdata
}
