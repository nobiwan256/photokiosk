##############################
# Variables
##############################

# Project Settings
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

# Network Configuration
variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_1" {
  description = "Availability zone for public subnet 1 and instance"
  type        = string
  default     = "us-west-2a"
}

variable "availability_zone_2" {
  description = "Availability zone for public subnet 2"
  type        = string
  default     = "us-west-2b"
}

variable "public_subnet_cidr_1" {
  description = "CIDR for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  description = "CIDR for public subnet 2"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_1" {
  description = "CIDR for private subnet 1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_2" {
  description = "CIDR for private subnet 2"
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

# EC2 Instance Settings
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0230bd60aa48260c6"
}

variable "key_name" {
  description = "Key name for SSH access"
  type        = string
  default     = "capstone_key"
}

# RDS Database Settings
variable "rds_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "sriwp_dbuser"
}

variable "rds_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
  default     = "SecurePassword123!"  # ✅ Default value added
}

variable "rds_db_name" {
  description = "Database name for the RDS instance"
  type        = string
  default     = "wordpress_db"
}

# S3 Bucket
variable "s3_bucket_name" {
  description = "Name of the S3 bucket for WordPress files"
  type        = string
  default     = "wordpress-bucket"  # ✅ Default value added
}
