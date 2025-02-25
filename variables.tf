variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "photokiosk"
}

variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0230bd60aa48260c6"  # Amazon Linux 2
}

variable "key_name" {
  description = "Key name for SSH access"
  type        = string
  default     = "capstone_key"
}

variable "availability_zone_1" {
  description = "Availability zone public subnet 1 and instance"
  type        = string
  default     = "us-west-2a"
}

variable "availability_zone_2" {
  description = "Availability zone public subnet 2"
  type        = string
  default     = "us-west-2b"
}

variable "public_subnet_cidr_1" {
  description = "CIDR public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  description = "CIDR public subnet 2"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_1" {
  description = "CIDR private subnet 1 for RDS"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_2" {
  description = "CIDR private subnet 2 for RDS"
  type        = string
  default     = "10.0.4.0/24"
}

variable "ssh_cidr_block" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "egress_cidr_block" {
  description = "CIDR block for outbound traffic"
  type        = string
  default     = "0.0.0.0/0"
}

variable "rds_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "sriwp_dbuser"
  sensitive   = true
}

variable "rds_password" {
  description = "Password for the RDS instance"
  type        = string
  default     = "Password123!#$"
  sensitive   = true
}

variable "rds_db_name" {
  description = "Database name for the RDS instance"
  type        = string
  default     = "wordpress_db"
}

variable "asg_min_size" {
  description = "Minimum size for the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size for the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
  default     = 1
}

# New variables to resolve errors
variable "aws_access_key_id" {
  description = "ASIAXPJ3LA3OWTQRI727"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "ua9KS+WS2R9gcsCXATGY7O0Kw52TCipSgJQjbWz4"
  type        = string
  sensitive   = true
}

variable "token" {
  description = "AWS Session Token"
  type        = string
  sensitive   = true
  default     = "IQoJb3JpZ2luX2VjEAgaCXVzLXdlc3QtMiJHMEUCIFcQzivSK9N8TTOpOC16qh5CcTzpDEgZ3+rQiE3+dzbaAiEAnUtzQTL7B2QiSLcI1d/bkPhhnqpnsP/LXotMhsmxXEEqpgIIQRABGgw1MTM5MDk5MTc0MDUiDOBLhpfGuf7pCpqGKiqDAnx1f0vpKL9qAxtBJ3pKQqooKXOTN4Oer9fnRFMpDdFDk94Rkc6LKdaMj2tiMBlg+yORDI/aWX/KsI30Gl8PjUPqfWmhYh3OaVucghlnzO7+4a3FHa7VK6JXiAae4UGW2LU0Eye/A/4oIVxGadKoLMIdw/qJHcKFSa31+2WGleZuzOu4rpDFK8HD8Q+C8oNvHqVwU63QX/AWpc9+CZ/NtVAyX/gE+X6WaMCX3NxKUWb+1/Xv3wXiCM0844OAw1EnFl5RmsGqup56fIGmXur2qP2e9Xr66F28Me4McB1XIKUjYNE56bdTatAlt5L+pz2MK58ni9Dp0uNkaQqzBMjKG4gSgp8w9vX1vQY6nQFyXEgxRLB+1a9wGS95iwB3rISiIc8i4Kgumos5FYfDS0k51W89hUmB3LtMAp+ACekqBs6/3sH6gsAkpl2wD0fGLUm2zbgXjtgU4SKtc/LvLoT+KqtCU1oayjoND3I2W2sDazNAlqVDbtOXcux6PYF1SVvtnRMA2y4gNC4PiAac8QLm0cYDan4IeNg/m08LyuP1gyFuJnyBvd86wcGx"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for WordPress assets"
  type        = string
  default     = "photokiosk000256"
}
