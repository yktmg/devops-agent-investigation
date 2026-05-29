import boto3
import os
import json

def lambda_handler(event, context):
    client = boto3.client('devops-agent', region_name='us-east-1')
    agent_space_id = os.environ['AGENT_SPACE_ID']

    response = client.create_backlog_task(
        agentSpaceId=agent_space_id,
        taskType='INVESTIGATION',
        title='CloudWatch Alarm triggered',
        description='Automated investigation triggered by CloudWatch Alarm.',
        priority='HIGH'
    )

    print(f"Investigation created: {json.dumps(response, default=str)}")
    return {"taskId": response["task"]["taskId"]}
