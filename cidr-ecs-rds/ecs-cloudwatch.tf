resource "aws_cloudwatch_log_group" "cidr" {
  name              = local.awslogs_group_name
  retention_in_days = 1

  tags = local.default_tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs" {
  name = "ecs-task-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.default_tags
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs" {
  name = "ecs-role-policy"
  role = aws_iam_role.ecs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      },
    ]
  })
}
