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
  region = "us-west-2"
  # For local development, you can add your credentials here
  # But for production, use environment variables or IAM roles
  # access_key = "your-access-key"
  # secret_key = "your-secret-key"
}
