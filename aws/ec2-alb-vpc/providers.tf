provider "aws" {
  profile = var.profile
  shared_credentials_files = ["/home/davidjir/.aws/credentials"]
  region = var.region
}