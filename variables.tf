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
  description = "AMI ID for the EC2 instance (must be valid in us-west-2)"
  type        = string
  default     = "ami-0c5204531f799e0c6"
}

variable "key_name" {
  description = "Key name for SSH access"
  type        = string
  default     = "capstone_key"
}

variable "availability_zone_1" {
  description = "Availability zone for public subnet 1 and EC2 instance"
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

variable "s3_bucket_name" {
  description = "The S3 bucket name for storing WordPress files"
  type        = string
  default     = "photokiosk000256"
}

variable "wordpress_rds_endpoint" {
  description = "Endpoint for the WordPress RDS database"
  type        = string
  default     = "localhost"
}
