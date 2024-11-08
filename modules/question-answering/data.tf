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
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch.question_answering_api.log_group_name}/*",
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
      awscc_events_event_bus.question_answering.arn,
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

    resources = ["*"]
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

    actions = ["bedrock:*"]
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

  statement {
    sid = "KMSAccess"
    actions = ["kms:*"]
    effect = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "XRayAccess"

    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AOSSAccess"
    actions = ["aoss:*"]
    effect = "Allow"
    resources = ["*"]
  }
  #checkov:skip=CKV_AWS_356:Lambda VPC and Xray permission require wildcard
  #checkov:skip=CKV_AWS_111:Lambda VPC and Xray permission require wildcard
  #checkov:skip=CKV_AWS_109:KMS management permission by IAM user
  #checkov:skip=CKV_AWS_111:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_356:wildcard permission required for kms key
}

data "aws_iam_policy_document" "question_answering_kms_key" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }

  statement {
    sid    = "Allow Service CloudWatchLogGroup"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:Describe*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:${data.aws_partition.current.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.solution_prefix}*",
        "arn:${data.aws_partition.current.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/state/${var.solution_prefix}*",
        "arn:${data.aws_partition.current.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/appsync/apis/*",
      ]
    }
  }

  statement {
    sid    = "Allow Service EventBus"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:events:event-bus:arn"
      values = [
        "arn:${data.aws_partition.current.id}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${var.solution_prefix}*",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.id}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${var.solution_prefix}*",
      ]
    }
  }
  #checkov:skip=CKV_AWS_109:KMS management permission by IAM user
  #checkov:skip=CKV_AWS_111:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_356:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_109:KMS management permission by IAM user
}