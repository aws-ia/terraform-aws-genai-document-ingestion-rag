data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_iam_policy_document" "ingestion_api_log" {
  statement {
    sid = "IngestionApiLogPermissions"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "ingestion_api_datasource" {
  statement {
    sid = "IngestionApiPermissions"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

# data "aws_iam_policy_document" "ecr_kms_key" {
#   statement {
#     actions = ["kms:*"]
#     resources = ["*"]
#     principals {
#       identifiers = [aws_iam_role.lambda_exec_role.arn]
#       type = "AWS"
#     }
#   }
#   statement {
#     sid = "Allow access for Key Administrators"
#     actions = ["kms:*"]
#     resources = ["*"]
#     principals {
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#       type = "AWS"
#     }
#   }
# }
