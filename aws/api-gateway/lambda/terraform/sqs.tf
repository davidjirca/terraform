# Dead Letter Queue for failed messages
resource "aws_sqs_queue" "message_queue_dlq" {
  name                      = "${var.project_name}-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.project_name}-dlq"
    Environment = var.environment
  }
}

# main SQS Queue
resource "aws_sqs_queue" "message_queue" {
  name = "${var.project_name}-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds = var.sqs_message_retention
  delay_seconds = 0
  max_message_size = 262144 # 256 KB
  receive_wait_time_seconds = 0

  # Configure dead letter queue
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.message_queue_dlq.arn
    maxReceiveCount = 3
  })

  tags = {
    Name = "${var.project_name}-queue"
    Environment = var.environment
  }
}

# SQS Queue Policy (if needed for cross-account access or SNS)
resource "aws_sqs_queue_policy" "message_queue_policy" {
  queue_url = aws_sqs_queue.message_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.message_queue.arn
      }
    ]
  })
}