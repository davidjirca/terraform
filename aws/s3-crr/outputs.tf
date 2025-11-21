# ============================================
# BUCKET OUTPUTS
# ============================================

output "source_bucket_id" {
  description = "Name of the source S3 bucket"
  value       = aws_s3_bucket.source.id
}

output "source_bucket_arn" {
  description = "ARN of the source S3 bucket"
  value       = aws_s3_bucket.source.arn
}

output "destination_bucket_id" {
  description = "Name of the destination S3 bucket"
  value       = aws_s3_bucket.destination.id
}

output "destination_bucket_arn" {
  description = "ARN of the destination S3 bucket"
  value       = aws_s3_bucket.destination.arn
}

# ============================================
# KMS KEY OUTPUTS
# ============================================

output "source_kms_key_id" {
  description = "ID of the source KMS key"
  value       = aws_kms_key.source.id
}

output "source_kms_key_arn" {
  description = "ARN of the source KMS key"
  value       = aws_kms_key.source.arn
}

output "source_kms_alias" {
  description = "Alias of the source KMS key"
  value       = aws_kms_alias.source.name
}

output "destination_kms_key_id" {
  description = "ID of the destination KMS key"
  value       = aws_kms_key.destination.id
}

output "destination_kms_key_arn" {
  description = "ARN of the destination KMS key"
  value       = aws_kms_key.destination.arn
}

output "destination_kms_alias" {
  description = "Alias of the destination KMS key"
  value       = aws_kms_alias.destination.name
}

# ============================================
# IAM OUTPUTS
# ============================================

output "replication_role_arn" {
  description = "ARN of the IAM replication role"
  value       = aws_iam_role.replication.arn
}

output "replication_role_name" {
  description = "Name of the IAM replication role"
  value       = aws_iam_role.replication.name
}

# ============================================
# REGION OUTPUTS
# ============================================

output "source_region" {
  description = "Source bucket region"
  value       = var.source_region
}

output "destination_region" {
  description = "Destination bucket region"
  value       = var.destination_region
}

# ============================================
# TESTING INSTRUCTIONS
# ============================================

output "testing_instructions" {
  description = "Instructions for testing S3 replication"
  value       = <<-EOT
    
    S3 Cross-Region Replication Setup Complete!
    
    To test replication:
    
    1. Create a test file:
       echo "Testing S3 replication" > test.txt
    
    2. Upload to source bucket:
       aws s3 cp test.txt s3://${aws_s3_bucket.source.id}/ \
         --sse aws:kms \
         --sse-kms-key-id ${aws_kms_key.source.id}
    
    3. Wait 5-15 minutes for replication
    
    4. Check destination bucket:
       aws s3 ls s3://${aws_s3_bucket.destination.id}/
    
    5. Verify object metadata:
       aws s3api head-object \
         --bucket ${aws_s3_bucket.destination.id} \
         --key test.txt \
         --region ${var.destination_region}
    
    6. Monitor replication metrics:
       - CloudWatch Console → Metrics → S3 → Replication
       - Look for "ReplicationLatency" and "BytesPendingReplication"
    
    Source Bucket: ${aws_s3_bucket.source.id}
    Destination Bucket: ${aws_s3_bucket.destination.id}
    Replication Status: ${var.replication_rule_status}
  EOT
}

output "replication_configuration" {
  description = "Summary of replication configuration"
  value = {
    source_bucket      = aws_s3_bucket.source.id
    destination_bucket = aws_s3_bucket.destination.id
    source_region      = var.source_region
    destination_region = var.destination_region
    storage_class      = var.replication_storage_class
    delete_markers     = var.replicate_delete_markers
    prefix_filter      = var.replication_prefix != "" ? var.replication_prefix : "all objects"
    status             = var.replication_rule_status
  }
}