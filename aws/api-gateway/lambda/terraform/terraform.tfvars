# Copy this file to terraform.tfvars and fill in your values
# Do not commit terraform.tfvars to version control

aws_region     = "us-east-1"
project_name   = "serverless-app"
environment    = "dev"
verified_email = "your-email@gmail.com"  # Replace with your Gmail address

# Optional: Override default values
# lambda_runtime          = "python3.11"
# lambda_timeout          = 30
# lambda_memory_size      = 256
# sqs_visibility_timeout  = 60
# sqs_message_retention   = 345600