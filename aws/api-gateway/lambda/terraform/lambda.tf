# Data source to package Lambda functions
data "archive_file" "api_handler_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/api_handler"
  output_path = "${path.module}/../lambda/packages/api_handler.zip"
}

data "archive_file" "queue_processor_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/queue_processor"
  output_path = "${path.module}/../lambda/packages/queue_processor.zip"
}

data "archive_file" "status_checker_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/status_checker"
  output_path = "${path.module}/../lambda/packages/status_checker.zip"
}

# API Handler Lambda Function
resource "aws_lambda_function" "api_handler" {
  filename         = data.archive_file.api_handler_zip.output_path
  function_name    = "${var.project_name}-api-handler"
  role            = aws_iam_role.api_handler_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.api_handler_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.message_queue.url
    }
  }

  tags = {
    Name        = "${var.project_name}-api-handler"
    Environment = var.environment
  }
}

# CloudWatch Log Group for API Handler
resource "aws_cloudwatch_log_group" "api_handler_logs" {
  name              = "/aws/lambda/${aws_lambda_function.api_handler.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-api-handler-logs"
    Environment = var.environment
  }
}

# Queue Processor Lambda Function
resource "aws_lambda_function" "queue_processor" {
  filename         = data.archive_file.queue_processor_zip.output_path
  function_name    = "${var.project_name}-queue-processor"
  role            = aws_iam_role.queue_processor_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.queue_processor_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_topic.arn
    }
  }

  tags = {
    Name        = "${var.project_name}-queue-processor"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Queue Processor
resource "aws_cloudwatch_log_group" "queue_processor_logs" {
  name              = "/aws/lambda/${aws_lambda_function.queue_processor.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-queue-processor-logs"
    Environment = var.environment
  }
}

# Event Source Mapping - SQS to Queue Processor Lambda
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.message_queue.arn
  function_name    = aws_lambda_function.queue_processor.arn
  batch_size       = 10
  enabled          = true

  # Function response types for partial batch failures
  function_response_types = ["ReportBatchItemFailures"]
}

# Status Checker Lambda Function
resource "aws_lambda_function" "status_checker" {
  filename         = data.archive_file.status_checker_zip.output_path
  function_name    = "${var.project_name}-status-checker"
  role            = aws_iam_role.status_checker_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.status_checker_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  tags = {
    Name        = "${var.project_name}-status-checker"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Status Checker
resource "aws_cloudwatch_log_group" "status_checker_logs" {
  name              = "/aws/lambda/${aws_lambda_function.status_checker.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-status-checker-logs"
    Environment = var.environment
  }
}