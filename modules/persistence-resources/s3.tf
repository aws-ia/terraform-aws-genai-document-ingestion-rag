# Input Access Logs bucket
resource "aws_s3_bucket" "access_logs_bucket" {
  bucket = "access_logs_bucket-${var.stage}"
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "access_logs_bucket_ownership_controls" {
  bucket = aws_s3_bucket.access_logs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "access_logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.access_logs_bucket_ownership_controls]

  bucket = aws_s3_bucket.access_logs_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "access_logs_bucket_versioning" {
  bucket = aws_s3_bucket.access_logs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "access_logs_bucket_policy" {
  bucket = aws_s3_bucket.access_logs_bucket.id
  policy = data.aws_iam_policy_document.access_logs_bucket_policy.json
}

# Input Assets bucket
resource "aws_s3_bucket" "input_assets_bucket" {
  bucket = "input_assets_bucket-${var.stage}"
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "input_assets_bucket_ownership_controls" {
  bucket = aws_s3_bucket.input_assets_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "input_assets_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.input_assets_bucket_ownership_controls]

  bucket = aws_s3_bucket.access_logs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "input_assets_bucket_versioning" {
  bucket = aws_s3_bucket.input_assets_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "input_assets_bucket_cors_configuration" {
  bucket = aws_s3_bucket.input_assets_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "Access-Control-Allow-Origin"]
  }
}

resource "aws_s3_bucket_logging" "input_assets_bucket_logging" {
  bucket = aws_s3_bucket.input_assets_bucket.id

  target_bucket = aws_s3_bucket.access_logs_bucket.id
  target_prefix = "inputsAssetsBucketLogs/"
}

resource "aws_s3_bucket_policy" "input_assets_bucket_policy" {
  bucket = aws_s3_bucket.input_assets_bucket.id
  policy = data.aws_iam_policy_document.input_assets_bucket_policy.json
}

# Processed Assets bucket
resource "aws_s3_bucket" "processed_assets_bucket" {
  bucket = "processed_assets_bucket-${var.stage}"
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "processed_assets_bucket_ownership_controls" {
  bucket = aws_s3_bucket.processed_assets_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "processed_assets_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.processed_assets_bucket_ownership_controls]
  bucket = aws_s3_bucket.processed_assets_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "processed_assets_bucket_versioning" {
  bucket = aws_s3_bucket.processed_assets_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "processed_assets_bucket_configuration" {
  bucket = aws_s3_bucket.processed_assets_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "Access-Control-Allow-Origin"]
  }
}

resource "aws_s3_bucket_logging" "processed_assets_bucket_logging" {
  bucket = aws_s3_bucket.processed_assets_bucket.id

  target_bucket = aws_s3_bucket.access_logs_bucket.id
  target_prefix = "processedAssetsBucketLogs/"
}

resource "aws_s3_bucket_policy" "processed_assets_bucket_policy" {
  bucket = aws_s3_bucket.processed_assets_bucket.id
  policy = data.aws_iam_policy_document.processed_assets_bucket_policy.json
}