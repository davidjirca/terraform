terraform {
  required_version = ">=1.8"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 5.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

  backend "local" {
    
  }
}

provider "aws" {
  profile = var.profile
  shared_credentials_files = ["/home/davidjir/.aws/credentials"]
  region = var.aws_region

  default_tags {
    tags = {
      Project = var.project_name
      Environment = var.environment
      ManagedBy = "Terraform"
    }
  }
}