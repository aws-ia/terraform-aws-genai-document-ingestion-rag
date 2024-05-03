# Bucket for storing server access logging
resource "aws_s3_bucket" "server_access_log_bucket" {
  bucket_prefix = "server-access-log-bucket-${var.stage}"
  force_destroy = false
}
resource "aws_s3_bucket_acl" "server_access_log_bucket_acl" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "server_access_log_bucket_encryption" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_versioning" "server_access_log_bucket_versioning" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "server_access_log_bucket_lifecycle" {
  bucket = aws_s3_bucket.server_access_log_bucket.bucket
  rule {
    id     = "server_access_log_bucket"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}
resource "aws_s3_bucket_policy" "server_access_log_bucket_policy" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  policy = data.aws_iam_policy_document.server_access_log_bucket_policy.json
}

# Bucket containing the inputs assets (documents - text format) uploaded by the user
resource "aws_s3_bucket" "input_assets_qa_bucket" {
  bucket = local.bucket_inputs_assets_props_bool ? var.bucket_inputs_assets_props.bucket_name : "input-asset-qa-bucket${var.stage}-${data.aws_caller_identity.current.account_id}"
}
resource "aws_s3_bucket_public_access_block" "input_assets_qa_bucket_public_access_block" {
  bucket = aws_s3_bucket.input_assets_qa_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "input_assets_qa_bucket_acl" {
  bucket = local.input_assets_bucket_id
  acl    = "private"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "input_assets_qa_bucket_encryption" {
  bucket = local.input_assets_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "input_assets_qa_bucket_versioning" {
  bucket = local.input_assets_bucket_id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "input_assets_qa_bucket_lifecycle" {
  bucket = local.input_assets_bucket_name
  rule {
    id     = "input_assets_qa_bucket"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}