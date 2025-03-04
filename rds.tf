# Create a DB subnet group using the private subnets for the RDS instance
resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name        = "${var.project_name}-db-subnet-group"
  description = "DB subnet group for WordPress RDS"
  subnet_ids  = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.env
  }
}

# RDS instance for WordPress
resource "aws_db_instance" "wordpress_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.wordpress_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  backup_retention_period = 7
  deletion_protection    = false
  multi_az               = true    # Keep Multi-AZ for high availability
  apply_immediately      = true
  # Remove the availability_zone parameter

  tags = {
    Name = "${var.project_name}-wordpress-db"
  }
  
  depends_on = [
    aws_db_subnet_group.wordpress_db_subnet_group,
    aws_security_group.rds_sg
  ]
}
