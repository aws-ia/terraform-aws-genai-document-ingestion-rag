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
      "*",
    ]
  }
}

data "aws_iam_policy_document" "summarization_api_datasource" {
  statement {
    sid = "SummarizationApiPermissions"

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

  statement {
    sid = "StateMachine"

    actions = [
      "states:StartExecution"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
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
}

# data "aws_iam_policy_document" "summarization_construct_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type = "Service"
#       #       identifiers = ["events.amazonaws.com"]
#       identifiers = ["appsync.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# data "aws_iam_policy_document" "summarization_construct_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#     ]
#     resources = ["*"]
#   }
# }

# data "aws_iam_policy_document" "firehose_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       identifiers = ["firehose.amazonaws.com"]
#       type        = "Service"
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# data "aws_iam_policy_document" "firehose_to_s3_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:AbortMultipartUpload",
#       "s3:GetBucketLocation",
#       "s3:GetObject",
#       "s3:ListBucket",
#       "s3:ListBucketMultipartUploads",
#       "s3:PutObject"
#     ]
#     resources = ["${aws_s3_bucket.waf_logs.arn}/*"]
#   }
# }
