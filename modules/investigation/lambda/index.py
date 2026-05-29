import boto3
import os

def lambda_handler(event, context):
    client = boto3.client('devops-agent', region_name='us-east-1')
    agent_space_id = os.environ['AGENT_SPACE_ID']

    response = client.start_investigation(
        agentSpaceId=agent_space_id
    )

    print(f"Investigation started: {response}")
    return response
