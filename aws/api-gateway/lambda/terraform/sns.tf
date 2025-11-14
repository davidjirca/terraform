# SNS Topic for email notifications
resource "aws_sns_topic" "email_topic" {
  name = "${var.project_name}-email-topic"

  tags = {
    Name        = "${var.project_name}-email-topic"
    Environment = var.environment
  }
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "email_topic_policy" {
  arn = aws_sns_topic.email_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.email_topic.arn
      }
    ]
  })
}

# SNS Email Subscription
# Note: This will send a confirmation email that must be manually confirmed
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "email"
  endpoint  = var.verified_email

  # The subscription will be in "PendingConfirmation" state until confirmed via email
}

# Output to remind user about email confirmation
output "sns_subscription_note" {
  value = "IMPORTANT: Check ${var.verified_email} for SNS subscription confirmation email"
}