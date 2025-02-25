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
}
