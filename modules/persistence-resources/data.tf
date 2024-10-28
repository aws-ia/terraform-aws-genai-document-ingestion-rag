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

data "aws_iam_policy_document" "persistent_resources_kms_key" {
  statement {
    sid = "AllowECR"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["ecr.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ecr.${data.aws_region.current.name}.amazonaws.com"]
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
    sid = "Allow Service CloudWatchLogGroup"
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
  #checkov:skip=CKV_AWS_109:KMS management permission by IAM user
  #checkov:skip=CKV_AWS_111:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_356:wildcard permission required for kms key
}

data "aws_iam_policy_document" "merged_api" {
  statement {
    sid = "MergeApiPermissions"

    actions = [
      "appsync:SourceGraphQL",
      "appsync:StartSchemaMerge"
    ]

    effect = "Allow"

    resources = var.target_merge_apis

  }
}

data "aws_iam_policy_document" "merged_api_addition" {
  statement {
    sid = "MergeApiPermissions2"

    actions = [
      "appsync:SourceGraphQL",
      "appsync:StartSchemaMerge"
    ]

    effect = "Allow"

    resources = [data.aws_cloudformation_export.merged_api_arn.value]

  }
}

data "aws_iam_policy_document" "authenticated_cognito" {
  statement {
    sid = "InputBucketAccess"

    actions = [
      "s3:Abort*",
      "s3:DeleteObject*",
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*",
      "s3:PutObject",
      "s3:PutObjectLegalHold",
      "s3:PutObjectRetention",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]

    effect = "Allow"

    resources = [
      aws_s3_bucket.input_assets.arn,
      "${aws_s3_bucket.input_assets.arn}/*",
    ]
  }

  # GetObject, GetBucket and List permission to processed bucket
  statement {
    sid = "OutputBucketAccess"

    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
    ]

    effect = "Allow"

    resources = [
      aws_s3_bucket.processed_assets.arn,
      "${aws_s3_bucket.processed_assets.arn}/*",
    ]
  }

  statement {
    sid = "KMSAccess"

    actions = ["kms:*"]

    effect = "Allow"

    resources = ["*"]
  }
  #checkov:skip=CKV_AWS_109:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_111:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_356:wildcard permission required for kms key
}

data "aws_cloudformation_export" "merged_api_id" {
  name       = local.graphql.merged_api.export_id
  depends_on = [aws_cloudformation_stack.merged_api]
}

data "aws_cloudformation_export" "merged_api_url" {
  name       = local.graphql.merged_api.export_url
  depends_on = [aws_cloudformation_stack.merged_api]
}

data "aws_cloudformation_export" "merged_api_arn" {
  name       = local.graphql.merged_api.export_arn
  depends_on = [aws_cloudformation_stack.merged_api]
}
