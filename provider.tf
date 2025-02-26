terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  cloud {
    organization = "nobiwan"
    workspaces {
      name = "photokiosk"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  # Credentials will be automatically pulled from environment variables
}
