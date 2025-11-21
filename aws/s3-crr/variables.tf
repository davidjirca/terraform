variable "project_name" {
  description = "Project name used for resource naming"
  type = string
  default = "s3-crr-demo"
}

variable "environment" {
  description = "Env name (dev, stg, prd)"
  type = string
  default = "dev"
}

variable "source_region" {
  description = "AWS region for the source S3 bucket"
  type = string
  default = "eu-central-1"
}

variable "destination_region" {
  description = "AWS region for the destination S3 bucket"
  type        = string
  default     = "eu-west-1"
}

variable "source_bucket_suffix" {
  description = "Suffix for source bucket name to ensure global uniqueness"
  type        = string
  default     = "20241121"
}

variable "destination_bucket_suffix" {
  description = "Suffix for destination bucket name to ensure global uniqueness"
  type        = string
  default     = "20241121"
}

variable "kms_key_deletion_window" {
  description = "Duration in days before KMS key deletion (7-30 days)"
  type        = number
  default     = 30

  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "enable_kms_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "replication_rule_status" {
  description = "Status of the replication rule (Enabled or Disabled)"
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.replication_rule_status)
    error_message = "Replication rule status must be either 'Enabled' or 'Disabled'."
  }
}

variable "replicate_delete_markers" {
  description = "Whether to replicate delete markers"
  type        = bool
  default     = false
}

variable "replication_storage_class" {
  description = "Storage class for replicated objects"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE", "GLACIER_IR"], var.replication_storage_class)
    error_message = "Invalid storage class specified."
  }
}

variable "replication_prefix" {
  description = "Optional prefix filter for replication (empty string replicates all objects)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "S3-CRR"
    ManagedBy   = "Terraform"
  }
}

variable "profile" {
  type = string
  default = "iamadmin"
}