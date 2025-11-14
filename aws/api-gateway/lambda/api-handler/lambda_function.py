import json
import boto3
import os
import uuid
from datetime import datetime

sqs = boto3.client('sqs')
QUEUE_URL = os.environ.get('SQS_QUEUE_URL')

def lambda_handler(event, context):
    try:
        # Parse the incoming request body
        body = json.loads(event.get('body', '{}'))
        
        # Validate required fields
        recipient = body.get('recipient')
        subject = body.get('subject')
        message_body = body.get('body')
        
        if not all([recipient, subject, message_body]):
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing required fields: recipient, subject, body'
                })
            }
        
        # Generate a unique message ID
        message_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat() + 'Z'
        
        # Prepare message for SQS
        sqs_message = {
            'message_id': message_id,
            'recipient': recipient,
            'subject': subject,
            'body': message_body,
            'timestamp': timestamp
        }
        
        # Send message to SQS
        response = sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(sqs_message)
        )
        
        print(f"Message sent to SQS: {message_id}")
        
        # Return success response
        return {
            'statusCode': 202,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message_id': message_id,
                'status': 'queued',
                'timestamp': timestamp
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }