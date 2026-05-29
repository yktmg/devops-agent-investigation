import boto3
import os
import json

def lambda_handler(event, context):
    client = boto3.client('devops-agent', region_name='us-east-1')
    agent_space_id = os.environ['AGENT_SPACE_ID']

    response = client.create_chat(
        agentSpaceId=agent_space_id,
        userType='IAM'
    )

    print(f"Investigation chat created: {json.dumps(response, default=str)}")
    return response
