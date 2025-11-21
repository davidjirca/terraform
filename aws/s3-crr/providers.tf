terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  shared_credentials_files = ["/home/davidjir/.aws/credentials"]
  region = var.source_region

    default_tags {
      tags = var.tags
  }
}


provider "aws" {
  alias = "destination"
  profile = var.profile
  shared_credentials_files = ["/home/davidjir/.aws/credentials"]
  region = var.destination_region

    default_tags {
      tags = var.tags
  }
}