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

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
  default     = "ASIAXPJ3LA3OSBKBDOPP"
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
  default     = "HD0zCsdW4DRiV6TiUdH37ZdZwDW1dG4CStG9UqUt"
}

variable "token" {
  description = "AWS Session Token"
  type        = string
  sensitive   = true
  default     = <<EOF
IQoJb3JpZ2luX2VjECYaCXVzLXdlc3QtMiJHMEUCIB73TajBe4UTvvwdmoqei2f7RIl8tpAtvX8FwQHx0NSfAiEAgmch3HugOgkQp47dQR0gdUc0DK92DPqSFaKrfnnov8UqpgIIXxABGgw1MTM5MDk5MTc0MDUiDA04rKPDkS/NJ4MwcyqDAho8xdwXGeJfqCY7yUdRlNc7PY5Yye/qmkzblrhTS7yo9idK8VGgimJACJKmD9dY8SDYhQgikbGqVsgl+f3rhV3dJlz+gPCqcsfZ58RU+VRhfDFvDtMJ2q2FVgY9WUuhmYPtIsAkaI0JGwlNIQgxEWageqxwJ8/U4mdTKNnYuyOn54OhSnwbW7Er6JTPeekgkcN1uRb2eWqT78sE9grBxBt+VrKomcJBV9xAKlU2ZsuPxKpjMSAdNdHBJxpdWP/ROwROj5m3vdkYVUSqv1vLI84Jh7OAFKDUifN3i0qDsKSwzhDDDi+hBRZreOrhXSrcecyvm+nocJA7zG4Ho4L3+9i0wgswlrn8vQY6nQGHQeBhMVRiFIFtEW1MzfKzIfAHNR6ndoYq8dkJ4ZIjVDG81GLGJ2G1DkwtZgMib2ZLX6YHZ7hG/I9UQwsWk96LE9ca9qRkOLsy4RAzyhDB4yJgyMN+qeH64Vgj/D5SuF8Xew2yfP/e4S79ZTr462c0fkdkZGfhiWhvAzjG65lGgTR3dv8LTiRo6Sfx/uIB/Db1ZrakmjZZBrmSUKxF
EOF
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for WordPress assets"
  type        = string
  default     = "photokiosk000256"
}
