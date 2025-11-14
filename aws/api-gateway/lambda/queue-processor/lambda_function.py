import json
import boto3
import os

sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')


def lambda_handler(event, context):
    try:
        # Process each record from SQS
        for record in event['Records']:
            # Parse the SQS message body
            message_body = json.loads(record['body'])
            
            message_id = message_body.get('message_id')
            recipient = message_body.get('recipient')
            subject = message_body.get('subject')
            body = message_body.get('body')
            timestamp = message_body.get('timestamp')
            
            print(f"Processing message: {message_id}")
            
            # Prepare SNS message with email details
            sns_message = {
                'default': json.dumps(message_body),
                'email': f"Subject: {subject}\n\n{body}\n\n---\nMessage ID: {message_id}\nTimestamp: {timestamp}"
            }
            
            # Publish to SNS
            response = sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps(sns_message),
                Subject=subject,
                MessageStructure='json'
            )
            
            print(f"Message published to SNS: {message_id}, SNS MessageId: {response['MessageId']}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Messages processed successfully'
            })
        }
        
    except Exception as e:
        print(f"Error processing message: {str(e)}")
        # Let Lambda retry by raising the exception
        raise e