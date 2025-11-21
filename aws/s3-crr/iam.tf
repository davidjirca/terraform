# ============================================
# IAM ROLE FOR S3 REPLICATION
# ============================================

# Trust policy for S3 replication service
data "aws_iam_policy_document" "replication_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create the replication role
resource "aws_iam_role" "replication" {
  name               = "${var.project_name}-s3-replication-role"
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-s3-replication-role"
    }
  )
}

# ============================================
# IAM POLICY FOR REPLICATION PERMISSIONS
# ============================================

data "aws_iam_policy_document" "replication_policy" {
  # Source bucket permissions
  statement {
    sid    = "SourceBucketPermissions"
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.source.arn
    ]
  }

  statement {
    sid    = "SourceObjectPermissions"
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]

    resources = [
      "${aws_s3_bucket.source.arn}/*"
    ]
  }

  # Destination bucket permissions
  statement {
    sid    = "DestinationBucketPermissions"
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    resources = [
      "${aws_s3_bucket.destination.arn}/*"
    ]
  }

  # Source KMS key permissions
  statement {
    sid    = "SourceKMSPermissions"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.source.arn
    ]
  }

  # Destination KMS key permissions
  statement {
    sid    = "DestinationKMSPermissions"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.destination.arn
    ]
  }
}

# Create the IAM policy
resource "aws_iam_policy" "replication" {
  name        = "${var.project_name}-s3-replication-policy"
  description = "Policy for S3 cross-region replication with KMS encryption"
  policy      = data.aws_iam_policy_document.replication_policy.json

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-s3-replication-policy"
    }
  )
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}