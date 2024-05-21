data "aws_iam_policy_document" "access_logs_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    effect = "Deny"

    resources = [
      aws_s3_bucket.access_logs_bucket.arn,
      "${aws_s3_bucket.access_logs_bucket.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "input_assets_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    effect = "Deny"

    resources = [
      aws_s3_bucket.input_assets_bucket.arn,
      "${aws_s3_bucket.input_assets_bucket.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "processed_assets_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    effect = "Deny"

    resources = [
      aws_s3_bucket.processed_assets_bucket.arn,
      "${aws_s3_bucket.processed_assets_bucket.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "opensearch_domain_policy" {
  count          = var.open_search-service_type == "es" ? 1 : 0
  statement {
    actions = [
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPost",
      "es:ESHttpPut"
    ]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.open_search_domain_name}/*"]
#     resources = ["${aws_opensearch_domain.opensearch_domain[0].arn}/*"]
  }
}