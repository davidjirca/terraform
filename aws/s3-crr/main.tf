# ============================================
# SOURCE S3 BUCKET (eu-central-1)
# ============================================

resource "aws_s3_bucket" "source" {
  bucket = "${var.project_name}-source-${var.source_bucket_suffix}"

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-source-bucket"
      Region = var.source_region
      Type   = "source"
    }
  )
}

# Enable versioning (required for replication)
resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.source.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "source" {
  bucket = aws_s3_bucket.source.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.source.arn
    }
    bucket_key_enabled = true
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "source" {
  bucket = aws_s3_bucket.source.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================
# REPLICATION CONFIGURATION
# ============================================

resource "aws_s3_bucket_replication_configuration" "source" {
  # Must have versioning enabled before replication
  depends_on = [
    aws_s3_bucket_versioning.source,
    aws_iam_role_policy_attachment.replication
  ]

  bucket = aws_s3_bucket.source.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "${var.project_name}-replication-rule"
    status = var.replication_rule_status

    # Optional: Filter by prefix
    dynamic "filter" {
      for_each = var.replication_prefix != "" ? [1] : []
      content {
        prefix = var.replication_prefix
      }
    }

    # If no prefix specified, use empty filter for all objects
    dynamic "filter" {
      for_each = var.replication_prefix == "" ? [1] : []
      content {
        # Empty filter replicates all objects
      }
    }

    # Configure delete marker replication
    delete_marker_replication {
      status = var.replicate_delete_markers ? "Enabled" : "Disabled"
    }

    # Destination configuration
    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = var.replication_storage_class

      # Encryption configuration for destination
      encryption_configuration {
        replica_kms_key_id = aws_kms_key.destination.arn
      }

      # Optional: Enable replication metrics
      metrics {
        status = "Enabled"
        event_threshold {
          minutes = 15
        }
      }

      # Optional: Enable replication time control for predictable replication
      replication_time {
        status = "Enabled"
        time {
          minutes = 15
        }
      }
    }
  }
}