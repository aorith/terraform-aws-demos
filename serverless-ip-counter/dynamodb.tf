data "aws_iam_policy_document" "ddb-rw" {
  statement {
    sid       = "ddbrw"
    effect    = "Allow"
    actions   = ["dynamodb:Scan", "dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
    resources = ["*"]
  }
}

resource "aws_dynamodb_table" "ip-counter" {
  name         = local.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "address"
  attribute {
    name = "address"
    type = "S"
  }
}
