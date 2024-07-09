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

data "aws_iam_policy_document" "ingestion_input_validation" {
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
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "ec2:DescribeNetworkInterfaces"
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
      "s3:PutObjectRetention",
      "s3:List*",
      "s3:GetBucket*",
      "s3:Abort*",
      "s3:DeleteObject*",
      "s3:PutObjectLegalHold",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
      "s3:PutObject",
      "s3:GetObject*"
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
      "${aws_appsync_graphql_api.ingestion_api.arn}/*"
    ]
  }

  statement {
    sid = "ECR"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "file_transformer" {
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
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "ec2:DescribeNetworkInterfaces"
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
      "s3:PutObjectRetention",
      "s3:List*",
      "s3:GetBucket*",
      "s3:Abort*",
      "s3:DeleteObject*",
      "s3:PutObjectLegalHold",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
      "s3:PutObject",
      "s3:GetObject*"
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
      "${aws_appsync_graphql_api.ingestion_api.arn}/*"
    ]
  }

  statement {
    sid = "ECR"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]

    effect = "Allow"

    resources = [
      "*"
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
