terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # If you're using Terraform Cloud, uncomment and modify these lines
  /*
  cloud {
    organization = "your-organization"
    workspaces {
      name = "photokiosk-workspace"
    }
  }
  */
}

provider "aws" {
  region                  = "us-west-2"
  access_key              = var.aws_access_key_id     # Use variable placeholders
  secret_key              = var.aws_secret_access_key
  token                   = var.aws_session_token
}

# Define variables
variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Session Token"
  type        = string
  sensitive   = true
}
