# ============================================
# DESTINATION S3 BUCKET (eu-west-1)
# ============================================

resource "aws_s3_bucket" "destination" {
  provider = aws.destination

  bucket = "${var.project_name}-destination-${var.destination_bucket_suffix}"

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-destination-bucket"
      Region = var.destination_region
      Type   = "destination"
    }
  )
}

# Enable versioning (required to receive replicated objects)
resource "aws_s3_bucket_versioning" "destination" {
  provider = aws.destination

  bucket = aws_s3_bucket.destination.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "destination" {
  provider = aws.destination

  bucket = aws_s3_bucket.destination.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.destination.arn
    }
    bucket_key_enabled = true
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "destination" {
  provider = aws.destination

  bucket = aws_s3_bucket.destination.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}