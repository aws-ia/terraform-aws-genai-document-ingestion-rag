data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_iam_policy_document" "summarization_api_log" {
  statement {
    sid = "SummarizationApiLogPermissions"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch.summarization_api.log_group_name}/*",
    ]
  }
}

data "aws_iam_policy_document" "summarization_api_datasource" {
  statement {
    sid = "EventBus"

    actions = [
      "events:PutEvents",
    ]

    effect = "Allow"

    resources = [
      awscc_events_event_bus.summarization.arn,
    ]
  }
}

data "aws_iam_policy_document" "summarization_sm" {

  statement {
    sid = "InvokeLambda"

    actions = [
      "lambda:InvokeFunction"
    ]

    effect = "Allow"

    resources = [
      aws_lambda_function.summarization_input_validation.arn,
      aws_lambda_function.summarization_doc_reader.arn,
      aws_lambda_function.summarization_generator.arn
    ]
  }

  statement {
    sid = "LogAndTelemetry"

    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogStream",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
  #checkov:skip=CKV_AWS_356:State machine log and Xray permission require wildcard
  #checkov:skip=CKV_AWS_111:State machine log and Xray permission require wildcard
}

data "aws_iam_policy_document" "summarization_sm_eventbridge" {

  statement {
    sid = "StartStateMachine"

    actions = [
      "states:StartExecution"
    ]

    effect = "Allow"

    resources = [
      aws_sfn_state_machine.summarization_sm.arn,
    ]
  }
}

data "aws_iam_policy_document" "summarization_sm_dlq" {

  statement {
    sid = "SecureTransport"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["sqs:*"]
    effect  = "Deny"

    resources = [
      aws_sqs_queue.summarization_sm_dlq.arn,
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid = "AllowEventBridgeDLQ"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sqs:SendMessage"]
    effect  = "Allow"

    resources = [
      aws_sqs_queue.summarization_sm_dlq.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.summarization.arn]
    }
  }
}

data "aws_iam_policy_document" "summarization_input_validation" {
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
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    effect = "Allow"

    resources = [
      var.input_assets_bucket_prop.bucket_arn,
      "${var.input_assets_bucket_prop.bucket_arn}/*",
      var.processed_assets_bucket_prop.bucket_arn,
      "${var.processed_assets_bucket_prop.bucket_arn}/*"
    ]
  }

  statement {
    sid = "AppSync"

    actions = [
      "appsync:GraphQL"
    ]

    effect = "Allow"

    resources = [
      "${aws_appsync_graphql_api.summarization_api.arn}/*"
    ]
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
    sid = "KMSAccess"
    actions = ["kms:*"]
    effect = "Allow"
    resources = ["*"]
  }
  #checkov:skip=CKV_AWS_356:Lambda VPC and Xray permission require wildcard
  #checkov:skip=CKV_AWS_111:Lambda VPC and Xray permission require wildcard
}

data "aws_iam_policy_document" "summarization_doc_reader" {
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
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      var.input_assets_bucket_prop.bucket_arn,
      "${var.input_assets_bucket_prop.bucket_arn}/*",
      var.processed_assets_bucket_prop.bucket_arn,
      "${var.processed_assets_bucket_prop.bucket_arn}/*"
    ]
  }

  statement {
    sid = "AppSync"

    actions = [
      "appsync:GraphQL"
    ]

    effect = "Allow"

    resources = [
      "${aws_appsync_graphql_api.summarization_api.arn}/*"
    ]
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
    sid = "KMSAccess"
    actions = ["kms:*"]
    effect = "Allow"
    resources = ["*"]
  }
  #checkov:skip=CKV_AWS_356:Lambda VPC and Xray permission require wildcard
  #checkov:skip=CKV_AWS_111:Lambda VPC and Xray permission require wildcard
}

data "aws_iam_policy_document" "summarization_generator" {
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
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      var.input_assets_bucket_prop.bucket_arn,
      "${var.input_assets_bucket_prop.bucket_arn}/*",
      var.processed_assets_bucket_prop.bucket_arn,
      "${var.processed_assets_bucket_prop.bucket_arn}/*"
    ]
  }

  statement {
    sid = "AppSync"

    actions = [
      "appsync:GraphQL"
    ]

    effect = "Allow"

    resources = [
      "${aws_appsync_graphql_api.summarization_api.arn}/*"
    ]
  }

  statement {
    sid = "Bedrock"

    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]

    effect = "Allow"

    resources = [
      "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/*"
    ]
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
    sid = "KMSAccess"
    actions = ["kms:*"]
    effect = "Allow"
    resources = ["*"]
  }
  #checkov:skip=CKV_AWS_356:Lambda VPC and Xray permission require wildcard
  #checkov:skip=CKV_AWS_111:Lambda VPC and Xray permission require wildcard
}

data "aws_iam_policy_document" "summarization_kms_key" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
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
}