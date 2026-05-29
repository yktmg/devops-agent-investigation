# Python コードを zip 化
data "archive_file" "notify_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/notify_lambda.zip"
}

# Lambda 実行ロール
resource "aws_iam_role" "notify_lambda" {
  name = "devops-agent-notify-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ログ出力権限(マネージドポリシー)
resource "aws_iam_role_policy_attachment" "notify_lambda_basic" {
  role       = aws_iam_role.notify_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Secrets Manager 読み取り権限(インラインポリシー・最小権限)
resource "aws_iam_role_policy" "notify_lambda_secrets" {
  name = "read-slack-webhook-secret"
  role = aws_iam_role.notify_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "secretsmanager:GetSecretValue"
      Effect   = "Allow"
      Resource = var.secret_arn
    }]
  })
}

# Lambda 本体
resource "aws_lambda_function" "notify" {
  function_name    = "devops-agent-notify"
  role             = aws_iam_role.notify_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  filename         = data.archive_file.notify_lambda.output_path
  source_code_hash = data.archive_file.notify_lambda.output_base64sha256

  environment {
    variables = {
      SECRET_ARN = var.secret_arn
    }
  }
}

# EventBridge ルール(調査開始/完了のみ拾う)
resource "aws_cloudwatch_event_rule" "devops_investigation" {
  name = "devops-agent-investigation-events"

  event_pattern = jsonencode({
    source      = ["aws.aidevops"]
    detail-type = ["Investigation In Progress", "Investigation Completed"]
  })
}

# ルールのターゲット = notify Lambda
resource "aws_cloudwatch_event_target" "notify" {
  rule = aws_cloudwatch_event_rule.devops_investigation.name
  arn  = aws_lambda_function.notify.arn
}

# EventBridge → Lambda の呼び出し許可
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.devops_investigation.arn
}
