# ============================================
# SOURCE BUCKET POLICY
# ============================================

data "aws_iam_policy_document" "source_bucket_policy" {
  # Deny unencrypted object uploads
  statement {
    sid    = "DenyUnencryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.source.arn}/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  # Deny incorrect encryption header (must be KMS)
  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.source.arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  # Require secure transport (HTTPS)
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.source.arn,
      "${aws_s3_bucket.source.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "source" {
  bucket = aws_s3_bucket.source.id
  policy = data.aws_iam_policy_document.source_bucket_policy.json
}

# ============================================
# DESTINATION BUCKET POLICY
# ============================================

data "aws_iam_policy_document" "destination_bucket_policy" {
  # Deny unencrypted object uploads
  statement {
    sid    = "DenyUnencryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.destination.arn}/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  # Deny incorrect encryption header (must be KMS)
  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.destination.arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  # Require secure transport (HTTPS)
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.destination.arn,
      "${aws_s3_bucket.destination.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Allow replication role to write replicated objects
  statement {
    sid    = "AllowReplicationRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication.arn]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:GetObjectVersionForReplication"
    ]

    resources = [
      "${aws_s3_bucket.destination.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "destination" {
  provider = aws.destination

  bucket = aws_s3_bucket.destination.id
  policy = data.aws_iam_policy_document.destination_bucket_policy.json
}