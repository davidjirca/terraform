# API Gateway outputs
output "api_gateway_url" {
  description = "Base URL for API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "post_endpoint" {
  description = "POST endpoint for sending messages"
  value       = "${aws_api_gateway_stage.main.invoke_url}/messages"
}

output "get_endpoint_example" {
  description = "GET endpoint for checking message status (replace {id} with message_id)"
  value       = "${aws_api_gateway_stage.main.invoke_url}/messages/{id}"
}

# Lambda outputs
output "api_handler_function_name" {
  description = "API Handler Lambda function name"
  value       = aws_lambda_function.api_handler.function_name
}

output "queue_processor_function_name" {
  description = "Queue Processor Lambda function name"
  value       = aws_lambda_function.queue_processor.function_name
}

output "status_checker_function_name" {
  description = "Status Checker Lambda function name"
  value       = aws_lambda_function.status_checker.function_name
}

# SQS outputs
output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.message_queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.message_queue.arn
}

output "sqs_dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = aws_sqs_queue.message_queue_dlq.url
}

# SNS outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.email_topic.arn
}

# SES outputs
output "ses_email_identity" {
  description = "SES verified email identity"
  value       = aws_ses_email_identity.sender_email.email
}

# CloudWatch Log Groups
output "api_handler_log_group" {
  description = "CloudWatch Log Group for API Handler"
  value       = aws_cloudwatch_log_group.api_handler_logs.name
}

output "queue_processor_log_group" {
  description = "CloudWatch Log Group for Queue Processor"
  value       = aws_cloudwatch_log_group.queue_processor_logs.name
}

output "status_checker_log_group" {
  description = "CloudWatch Log Group for Status Checker"
  value       = aws_cloudwatch_log_group.status_checker_logs.name
}

# Testing examples
output "curl_post_example" {
  description = "Example curl command to POST a message"
  value       = <<-EOT
    curl -X POST ${aws_api_gateway_stage.main.invoke_url}/messages \
      -H "Content-Type: application/json" \
      -d '{
        "recipient": "test@example.com",
        "subject": "Test Message",
        "body": "This is a test message from serverless app"
      }'
  EOT
}

output "curl_get_example" {
  description = "Example curl command to GET message status"
  value       = "curl -X GET ${aws_api_gateway_stage.main.invoke_url}/messages/<message-id>"
}