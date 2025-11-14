# SES Email Identity
resource "aws_ses_email_identity" "sender_email" {
  email = var.verified_email
}

# SES Configuration Set (optional, for tracking)
resource "aws_ses_configuration_set" "main" {
  name = "${var.project_name}-config-set"
}

# Output to remind user about email verification
output "ses_verification_note" {
  value = "IMPORTANT: Check ${var.verified_email} for SES verification email and click the verification link"
}

# Note: In sandbox mode, SES can only send TO verified addresses
# To send to any email address, you need to request production access via AWS Console