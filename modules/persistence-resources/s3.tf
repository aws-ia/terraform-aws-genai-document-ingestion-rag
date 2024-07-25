############################################################################################################
# Access Logs bucket
############################################################################################################
resource "aws_s3_bucket" "access_logs" {
  bucket_prefix = local.s3.access_logs.bucket
  force_destroy = var.force_destroy
  tags          = local.combined_tags
  #checkov:skip=CKV2_AWS_61: lifecycle config is optional
  #checkov:skip=CKV2_AWS_62: disable event notification
  #checkov:skip=CKV_AWS_144: cross-region replication is optional
  #checkov:skip=CKV_AWS_145: SSE-KMS not supported for access log
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  policy = data.aws_iam_policy_document.access_logs_bucket_policy.json
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  versioning_configuration {
    status = local.s3.access_logs.versioning_configuration_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  #checkov:skip=CKV2_AWS_67: KMS Key rotation is optional, if dictated by customer policies
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.s3.access_logs.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket                  = aws_s3_bucket.access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  rule {
    status = "Enabled"
    filter {
      prefix = "/"
    }
    id = "access_logs_lifecycle_configuration_rule"

    noncurrent_version_expiration {
      noncurrent_days = local.s3.access_logs.expiration_days
    }
  }

  rule {
    status = "Enabled"
    filter {}
    id = "abort_incomplete_multipart_uploads"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

############################################################################################################
# Input Assets bucket
############################################################################################################
resource "aws_s3_bucket" "input_assets" {
  bucket_prefix = local.s3.input_assets.bucket
  force_destroy = var.force_destroy
  tags          = local.combined_tags
  #checkov:skip=CKV2_AWS_61: lifecycle config is optional
  #checkov:skip=CKV2_AWS_62: disable event notification
  #checkov:skip=CKV_AWS_144: cross-region replication is optional
  #checkov:skip=CKV_AWS_145: SSE-KMS not supported for access log
}

resource "aws_s3_bucket_policy" "input_assets" {
  bucket = aws_s3_bucket.input_assets.id
  policy = data.aws_iam_policy_document.input_assets_bucket_policy.json
}

resource "aws_s3_bucket_versioning" "input_assets" {
  bucket = aws_s3_bucket.input_assets.id
  versioning_configuration {
    status = local.s3.input_assets.versioning_configuration_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "input_assets" {
  #checkov:skip=CKV2_AWS_67: KMS Key rotation is optional, if dictated by customer policies
  bucket = aws_s3_bucket.input_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.s3.input_assets.sse_algorithm
      kms_master_key_id = aws_kms_alias.persistent_resources.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "input_assets" {
  bucket                  = aws_s3_bucket.input_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "input_assets" {
  bucket = aws_s3_bucket.input_assets.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "inputsAssetsBucketLogs/"
}

resource "aws_s3_bucket_cors_configuration" "input_assets" {
  bucket = aws_s3_bucket.input_assets.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "Access-Control-Allow-Origin"]
  }
}
############################################################################################################
# Processed Assets bucket
############################################################################################################
resource "aws_s3_bucket" "processed_assets" {
  bucket_prefix = local.s3.processed_assets.bucket
  force_destroy = var.force_destroy
  tags          = local.combined_tags
  #checkov:skip=CKV2_AWS_61: lifecycle config is optional
  #checkov:skip=CKV2_AWS_62: disable event notification
  #checkov:skip=CKV_AWS_144: cross-region replication is optional
  #checkov:skip=CKV_AWS_145: SSE-KMS not supported for access log
}

resource "aws_s3_bucket_policy" "processed_assets" {
  bucket = aws_s3_bucket.processed_assets.id
  policy = data.aws_iam_policy_document.processed_assets_bucket_policy.json
}

resource "aws_s3_bucket_versioning" "processed_assets" {
  bucket = aws_s3_bucket.processed_assets.id
  versioning_configuration {
    status = local.s3.processed_assets.versioning_configuration_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_assets" {
  #checkov:skip=CKV2_AWS_67: KMS Key rotation is optional, if dictated by customer policies
  bucket = aws_s3_bucket.processed_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.s3.processed_assets.sse_algorithm
      kms_master_key_id = aws_kms_alias.persistent_resources.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "processed_assets" {
  bucket                  = aws_s3_bucket.processed_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "processed_assets" {
  bucket = aws_s3_bucket.processed_assets.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "processedAssetsBucketLogs/"
}

resource "aws_s3_bucket_cors_configuration" "processed_assets" {
  bucket = aws_s3_bucket.processed_assets.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "Access-Control-Allow-Origin"]
  }
}
