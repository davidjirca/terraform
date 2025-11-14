# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api"
  description = "REST API for serverless messaging application"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

# /messages resource
resource "aws_api_gateway_resource" "messages" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "messages"
}

# /messages/{id} resource
resource "aws_api_gateway_resource" "message_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.messages.id
  path_part   = "{id}"
}

# POST /messages method
resource "aws_api_gateway_method" "post_messages" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "POST"
  authorization = "NONE"
}

# POST /messages integration with Lambda
resource "aws_api_gateway_integration" "post_messages_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.messages.id
  http_method             = aws_api_gateway_method.post_messages.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}

# GET /messages/{id} method
resource "aws_api_gateway_method" "get_message" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.message_id.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

# GET /messages/{id} integration with Lambda
resource "aws_api_gateway_integration" "get_message_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.message_id.id
  http_method             = aws_api_gateway_method.get_message.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.status_checker.invoke_arn
}

# CORS configuration for POST /messages
resource "aws_api_gateway_method" "options_messages" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_messages_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options_messages.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_messages_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options_messages.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "options_messages_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options_messages.http_method
  status_code = aws_api_gateway_method_response.options_messages_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_messages_integration]
}

# CORS configuration for GET /messages/{id}
resource "aws_api_gateway_method" "options_message_id" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.message_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_message_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.message_id.id
  http_method = aws_api_gateway_method.options_message_id.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_message_id_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.message_id.id
  http_method = aws_api_gateway_method.options_message_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "options_message_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.message_id.id
  http_method = aws_api_gateway_method.options_message_id.http_method
  status_code = aws_api_gateway_method_response.options_message_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_message_id_integration]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [
    aws_api_gateway_integration.post_messages_integration,
    aws_api_gateway_integration.get_message_integration,
    aws_api_gateway_integration.options_messages_integration,
    aws_api_gateway_integration.options_message_id_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.messages.id,
      aws_api_gateway_resource.message_id.id,
      aws_api_gateway_method.post_messages.id,
      aws_api_gateway_method.get_message.id,
      aws_api_gateway_integration.post_messages_integration.id,
      aws_api_gateway_integration.get_message_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Lambda permissions for API Gateway to invoke functions
resource "aws_lambda_permission" "api_gateway_invoke_api_handler" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_status_checker" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.status_checker.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}