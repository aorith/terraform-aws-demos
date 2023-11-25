resource "aws_lambda_function" "ip_counter_lambda" {
  function_name = local.name
  description   = "Serverless IP counter"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.iam_lambda.arn
  runtime       = "python3.11"

  source_code_hash = data.archive_file.lambda_output.output_base64sha256
  filename         = data.archive_file.lambda_output.output_path

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.ip-counter.name
    }
  }
}

resource "aws_iam_role" "iam_lambda" {
  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy {
    name   = "ddbrw"
    policy = data.aws_iam_policy_document.ddb-rw.json
  }
}

data "archive_file" "lambda_output" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-code"
  output_path = "${path.module}/lambda-code.zip"
}

resource "aws_lambda_function_url" "url_1" {
  function_name      = aws_lambda_function.ip_counter_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
