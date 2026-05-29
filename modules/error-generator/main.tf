# Python コードを zip 化
data "archive_file" "error_generator" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/error_generator.zip"
}

# Lambda 実行ロール
resource "aws_iam_role" "error_generator" {
  name = "devops-agent-error-generator-role"

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

# ログ出力権限のみ(最小権限)
resource "aws_iam_role_policy_attachment" "error_generator_basic" {
  role       = aws_iam_role.error_generator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Log Group を明示的に作る(retention 設定のため)
resource "aws_cloudwatch_log_group" "error_generator" {
  name              = "/aws/lambda/${aws_lambda_function.error_generator.function_name}"
  retention_in_days = 7
}

# エラー発生 Lambda
resource "aws_lambda_function" "error_generator" {
  function_name    = "devops-agent-error-generator"
  role             = aws_iam_role.error_generator.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10
  filename         = data.archive_file.error_generator.output_path
  source_code_hash = data.archive_file.error_generator.output_base64sha256
}
