data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "appsync_service_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "question_answering_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}
data "aws_iam_policy_document" "question_answering_inline_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
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
    resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"]
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
    resources = [var.open_search_secret.arn]
  }
}

data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:GetObject*", "s3:GetBucket*", "s3:List*"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.input_assets_qa_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.input_assets_qa_bucket.bucket}/*",]
  }
}

data "aws_iam_policy_document" "opensearch_access_policy" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.existing_opensearch_domain.domain_name}/*",
      "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.existing_opensearch_domain.domain_name}",
    ]
    actions = ["es:*"]
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
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model",
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*",
    ]
  }
}

data "aws_iam_policy_document" "suppression_policy" {
  statement {
    effect = "Allow"
    actions = ["ssm:AddExcludedTargets"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "appsync_policy" {
  statement {
    effect = "Allow"
    resources = ["arn:aws:appsync:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:apis/${aws_appsync_graphql_api.question_answering_graphql_api.id}/*"]
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

data "aws_iam_policy_document" "server_access_log_bucket_policy" {
  statement {
    actions = ["sts:AssumeRole", "s3:PutObject"]
    effect = "Allow"
    principals {
      identifiers = ["vpc-flow-logs.amazonaws.com"]
      type        = "Service"
    }
  }
}
