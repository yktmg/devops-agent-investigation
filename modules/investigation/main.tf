# bridge-Lambda 実行ロール
resource "aws_iam_role" "investigation" {
  name = "devops-agent-investigation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Logs書き込み権限
resource "aws_iam_role_policy_attachment" "investigation_basic" {
  role       = aws_iam_role.investigation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DevOps Agent呼び出し権限
resource "aws_iam_role_policy" "investigation_devops_agent" {
  name = "invoke-devops-agent"
  role = aws_iam_role.investigation.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "aidevops:CreateChat"
      Resource = "*"
    }]
  })
}

# Lambdaコードをzip化
data "archive_file" "investigation" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/investigation.zip"
}

# bridge-Lambda
resource "aws_lambda_function" "investigation" {
  function_name    = "devops-agent-investigation"
  role             = aws_iam_role.investigation.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30
  layers           = ["arn:aws:lambda:us-east-1:756113445894:layer:boto3-devops-agent:1"]
  filename         = data.archive_file.investigation.output_path
  source_code_hash = data.archive_file.investigation.output_base64sha256

  environment {
    variables = {
      AGENT_SPACE_ID = var.agent_space_id
    }
  }
}

# CloudWatch Alarmの状態変化を検知するEventBridgeルール
resource "aws_cloudwatch_event_rule" "alarm_trigger" {
  name        = "devops-agent-alarm-trigger"
  description = "Triggers investigation when CloudWatch Alarm enters ALARM state"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    resources   = [var.alarm_arn]
    detail = {
      state = {
        value = ["ALARM"]
      }
    }
  })
}

# EventBridgeのターゲットにbridge-Lambdaを設定
resource "aws_cloudwatch_event_target" "investigation" {
  rule = aws_cloudwatch_event_rule.alarm_trigger.name
  arn  = aws_lambda_function.investigation.arn
}

# EventBridgeからLambdaを呼び出す権限
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.investigation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_trigger.arn
}

# CloudWatch Log Group（retention設定のため明示的に作成）
resource "aws_cloudwatch_log_group" "investigation" {
  name              = "/aws/lambda/${aws_lambda_function.investigation.function_name}"
  retention_in_days = 7
}
