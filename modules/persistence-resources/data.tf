data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "access_logs_bucket_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    effect  = "Allow"

    resources = [
      "${aws_s3_bucket.access_logs.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    effect  = "Deny"

    resources = [
      aws_s3_bucket.access_logs.arn,
      "${aws_s3_bucket.access_logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

#TODO: tidy up this policy
data "aws_iam_policy_document" "input_assets_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    effect  = "Deny"

    resources = [
      aws_s3_bucket.input_assets.arn,
      "${aws_s3_bucket.input_assets.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

#TODO: tidy up this policy
data "aws_iam_policy_document" "processed_assets_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    effect  = "Deny"

    resources = [
      aws_s3_bucket.processed_assets.arn,
      "${aws_s3_bucket.processed_assets.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "opensearch_domain_policy" {
  #checkov:skip=CKV2_AWS_40:scope by domain name
  count = var.open_search_service_type == "es" ? 1 : 0
  statement {

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }

    effect = "Allow"

    actions = [
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPost",
      "es:ESHttpPut"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.open_search_props.domain_name}/*"]
  }
}

data "aws_iam_policy_document" "app_kms_key" {
  statement {
    sid = "AllowECR"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["ecr.amazonaws.com"]
    }
  }

  statement {
    sid = "AllowOpenSearchServerless"
    actions = [
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["aoss.${data.aws_region.current.name}.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

  }

  statement {
    sid = "AllowS3Logging"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }

  statement {
    sid = "AllowRootUserAccess"
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# TODO: tidy up the permissions
data "aws_iam_policy_document" "merged_api" {
  statement {
    sid = "MergeApiPermissions"

    actions = [
        "appsync:*",
        "logs:*",
        "cloudwatch:*",
        "dynamodb:*",
        "lambda:*"
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

data "aws_cloudformation_export" "merged_api_id" {
  name       = local.graphql.merged_api.export_id
  depends_on = [aws_cloudformation_stack.merged_api]
}

data "aws_cloudformation_export" "merged_api_url" {
  name       = local.graphql.merged_api.export_url
  depends_on = [aws_cloudformation_stack.merged_api]
}
