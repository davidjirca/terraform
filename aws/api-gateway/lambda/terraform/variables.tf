variable "aws_region" {
  type = string
  default = "eu-central-1"
}

variable "profile" {
  type = string
  default = "iamadmin"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "serverless-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type = string
  default = "dev"
}

variable "verified_email" {
  description = "Verified email address for SES (must be verified in AWS SES)"
  type = string
}

variable "lambda_runtime" {
  description = "Python runtime version for Lambda functions"
  type = string
  default = "python3.11"
}

variable "lambda_timeout" {
  description = "Timeout in seconds for Lambda functions"
  type = number
  default = 30
}

variable "lambda_memory_size" {
  description = "Memory allocation for lambda functions in MB"
  type = number
  default = 256
}

variable "sqs_visibility_timeout" {
  description = "SQS message visibility timeout in seconds"
  type        = number
  default     = 60
}

variable "sqs_message_retention" {
  description = "SQS message retention period in seconds (4 days)"
  type        = number
  default     = 345600
}