import json
from datetime import datetime
import random


def lambda_handler(event, context):
    """
    Status Checker Lambda - returns mock status for GET requests
    In a real scenario, this would query DynamoDB or another data store
    """
    try:
        # Extract message_id from path parameters
        message_id = event.get('pathParameters', {}).get('id')
        
        if not message_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing message_id in path'
                })
            }
        
        # Mock status - randomly choose between 'queued', 'processing', 'sent'
        statuses = ['queued', 'processing', 'sent']
        mock_status = random.choice(statuses)
        
        # Generate mock response
        timestamp = datetime.utcnow().isoformat() + 'Z'
        
        response_data = {
            'message_id': message_id,
            'status': mock_status,
            'recipient': 'mock@example.com',
            'timestamp': timestamp
        }
        
        # Add additional fields based on status
        if mock_status == 'sent':
            response_data['sent_at'] = timestamp
            response_data['delivery_status'] = 'delivered'
        elif mock_status == 'processing':
            response_data['queued_at'] = timestamp
        
        print(f"Status check for message: {message_id}, status: {mock_status}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_data)
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
