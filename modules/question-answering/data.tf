data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_iam_policy_document" "question_answering_api_log" {
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

data "aws_iam_policy_document" "question_answering_api_event_bridge_datasource" {
  statement {
    sid = "EventBus"

    actions = [
      "events:PutEvents",
    ]

    effect = "Allow"

    resources = [
      aws_cloudwatch_event_bus.question_answering.arn,
    ]
  }
}

# TODO: verify required access for regular opensearch cluster
data "aws_iam_policy_document" "question_answering" {
  statement {
    sid = "CloudWatchLog"

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

  statement {
    sid = "EC2andVPC"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSubnets",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }

  statement {
    sid = "S3Access"

    actions = [
      "s3:GetObject",
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
    ]

    effect = "Allow"

    resources = [
      var.processed_assets_bucket_prop.bucket_arn,
      "${var.processed_assets_bucket_prop.bucket_arn}/*"
    ]
  }

  statement {
    sid = "Bedrock"

    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:ListFoundationModels",
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }

  statement {
    sid = "GraphQL"

    actions = [
      "appsync:GraphQL",
    ]

    effect = "Allow"

    resources = [
      "${var.merged_api_arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = var.opensearch_prop.type == "es" ? [local.opensearch_policy.es] : [local.opensearch_policy.aoss]
    content {
      sid = "OpenSearch"

      actions = statement.value.actions

      effect = "Allow"

      resources = [var.opensearch_prop.arn]
    }
  }
}