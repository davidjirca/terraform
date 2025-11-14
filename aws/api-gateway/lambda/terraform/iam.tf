# IAM Role for API Handler Lambda

resource "aws_iam_role" "api_handler_role" {
  name = "${var.project_name}-api-handler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-api-handler-role"
    Environment = var.environment
  }
}

# Policy for API Handler - CloudWatch Logs + SQS SendMessage
resource "aws_iam_role_policy" "api_handler_policy" {
  name = "${var.project_name}-api-handler-policy"
  role = aws_iam_role.api_handler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-api-handler:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.message_queue.arn
      }
    ]
  })
}

# IAM Role for Queue Processor Lambda
resource "aws_iam_role" "queue_processor_role" {
  name = "${var.project_name}-queue-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-queue-processor-role"
    Environment = var.environment
  }
}

# Policy for Queue Processor - CloudWatch Logs + SQS Receive/Delete + SNS Publish
resource "aws_iam_role_policy" "queue_processor_policy" {
  name = "${var.project_name}-queue-processor-policy"
  role = aws_iam_role.queue_processor_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-queue-processor:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.message_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.email_topic.arn
      }
    ]
  })
}

# IAM Role for Status Checker Lambda
resource "aws_iam_role" "status_checker_role" {
  name = "${var.project_name}-status-checker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-status-checker-role"
    Environment = var.environment
  }
}

# Policy for Status Checker - CloudWatch Logs only (mock response)
resource "aws_iam_role_policy" "status_checker_policy" {
  name = "${var.project_name}-status-checker-policy"
  role = aws_iam_role.status_checker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-status-checker:*"
      }
    ]
  })
}