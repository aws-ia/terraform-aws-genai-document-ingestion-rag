data "aws_region" "current_region" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "qa_construct_log_group_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
data "aws_iam_policy_document" "qa_construct_log_group_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "appsync_logging_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
data "aws_iam_policy_document" "appsync_logging_assume_role_publish_policy" {
  statement {
    effect = "Allow"
    actions = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.question_answering_event_bus.arn]
  }
}

data "aws_iam_policy_document" "job_status_data_source_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["appsync.amazonaws.com"]
      type = "Service"
    }
  }
}

data aws_iam_policy_document "job_status_data_source_role_policy" {
  statement {
    effect = "Allow"
    actions = ["dynamodb:*", "lambda:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "firehose_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["firehose.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "firehose_to_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.waf_logs.arn}/*"]
  }
}

data "aws_iam_policy_document" "question_answering_function_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "question_answering_function_inline_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "question_answering_function_policy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
    ]
    resources = ["arn:aws:ec2:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:*/*"]
    effect = "Allow"
  }
}
data "aws_iam_policy_document" "describe_network_interfaces_policy" {
  statement {
    actions = ["ec2:DescribeNetworkInterfaces"]
    resources = ["*"]
    effect = "Allow"
  }
}
data "aws_iam_policy_document" "open_search_secret_policy_document" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    effect = "Allow"
    resources = [var.open_search_secret]
  }
}

data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:GetBucket", "s3:ListBucket"]
    resources = [
      var.input_assets_bucket_arn,
      "${var.input_assets_bucket_arn}/*",]
  }
}

data "aws_iam_policy_document" "sqs_send_message_policy" {
  statement {
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.dlq.arn]
  }
}

data "aws_iam_policy_document" "opensearch_access_policy" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:es:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:domain/*",
      # TODO() validate  issue
 # "arn:aws:es:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:domain/${var.existing_opensearch_domain_mame}/*",
    ]
    actions = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost", "es:ESHttpDelete", "es:ESHttpHead"]
  }
}

data "aws_iam_policy_document" "bedrock_invoke_model_policy" {
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current_region.name}::foundation-model",
      "arn:aws:bedrock:${data.aws_region.current_region.name}::foundation-model/*",
    ]
  }
}
data "aws_iam_policy_document" "suppression_policy" {
  statement {
    effect = "Allow"
    actions = ["ssm:AddExcludedTargets"]
    resources = [
      "arn:aws:ssm:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:maintenancewindow-target/your-specific-target-id"
    ]
  }
}

data "aws_iam_policy_document" "appsync_policy" {
  statement {
    effect = "Allow"
    resources = ["arn:aws:appsync:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:apis/${aws_appsync_graphql_api.question_answering_graphql_api.id}/*"]
    actions = ["appsync:GraphQL"]
  }
}

data "aws_iam_policy_document" "qa_construct_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["vpc-flow-logs.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}
