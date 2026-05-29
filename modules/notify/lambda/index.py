import json
import os
import urllib.request

def lambda_handler(event, context):
    webhook_url = get_secret(os.environ["SECRET_ARN"])

    detail = event.get("detail", {})
    detail_type = event.get("detail-type", "")
    metadata = detail.get("metadata", {})
    data = detail.get("data", {})

    # 開始 / 完了 でメッセージを出し分け
    if detail_type == "Investigation In Progress":
        text = f":mag: *DevOps Agent 調査開始*\nTask ID: {metadata.get('task_id', '-')}"
    elif detail_type == "Investigation Completed":
        agent_space_id = metadata.get("agent_space_id", "")
        task_id = metadata.get("task_id", "")
        url = f"https://us-east-1.console.aws.amazon.com/aidevops/home?region=us-east-1#/agent-spaces/{agent_space_id}/investigations/{task_id}"
        text = f":white_check_mark: *DevOps Agent 調査完了*\nTask ID: {task_id}\n調査結果: <{url}|レポートを開く>"
    else:
        # 対象外の detail-type は無視(CloudTrail 混入対策)
        return {"statusCode": 200, "body": "ignored"}

    post_to_slack(webhook_url, text)
    return {"statusCode": 200}


def get_secret(secret_arn):
    import boto3
    client = boto3.client("secretsmanager")
    resp = client.get_secret_value(SecretId=secret_arn)
    return resp["SecretString"]


def post_to_slack(webhook_url, text):
    payload = json.dumps({"text": text}).encode("utf-8")
    req = urllib.request.Request(
        webhook_url,
        data=payload,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as res:
        res.read()
