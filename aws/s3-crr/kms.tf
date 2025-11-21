# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# ============================================
# SOURCE REGION KMS KEY (eu-central-1)
# ============================================

resource "aws_kms_key" "source" {
  description             = "KMS key for S3 source bucket encryption in ${var.source_region}"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.enable_kms_key_rotation

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-source-kms"
      Region = var.source_region
    }
  )
}

resource "aws_kms_alias" "source" {
  name          = "alias/${var.project_name}-source-s3"
  target_key_id = aws_kms_key.source.key_id
}

resource "aws_kms_key_policy" "source" {
  key_id = aws_kms_key.source.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow replication role to decrypt"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.replication.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================
# DESTINATION REGION KMS KEY (eu-west-1)
# ============================================

resource "aws_kms_key" "destination" {
  provider = aws.destination

  description             = "KMS key for S3 destination bucket encryption in ${var.destination_region}"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.enable_kms_key_rotation

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-destination-kms"
      Region = var.destination_region
    }
  )
}

resource "aws_kms_alias" "destination" {
  provider = aws.destination

  name          = "alias/${var.project_name}-destination-s3"
  target_key_id = aws_kms_key.destination.key_id
}

resource "aws_kms_key_policy" "destination" {
  provider = aws.destination
  key_id   = aws_kms_key.destination.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow replication role to encrypt"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.replication.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}