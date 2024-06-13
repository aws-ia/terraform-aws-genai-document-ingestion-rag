# S3 Bucket for Server Access Logs
resource "aws_s3_bucket" "server_access_log_bucket" {
  bucket = "server-access-log-bucket-${var.stage}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "Server Access Log Bucket"
    Environment = var.stage
  }
}

# S3 Buckets
resource "aws_s3_bucket" "input_assets_bucket" {
  bucket = "input-assets-bucket-${var.stage}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name        = "Input Assets Bucket"
    Environment = var.stage
  }
}

resource "aws_s3_bucket" "processed_assets_bucket" {
  bucket = "processed-assets-bucket-${var.stage}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name        = "Processed Assets Bucket"
    Environment = var.stage
  }
}

# Server Access Logging Configuration
resource "aws_s3_bucket_logging" "input_assets_bucket_logging" {
  bucket = aws_s3_bucket.input_assets_bucket.bucket

  target_bucket = aws_s3_bucket.server_access_log_bucket.bucket

  target_prefix = "input-assets-log/"
}

resource "aws_s3_bucket_logging" "processed_assets_bucket_logging" {
  bucket = aws_s3_bucket.processed_assets_bucket.bucket

  target_bucket = aws_s3_bucket.server_access_log_bucket.bucket

  target_prefix = "processed-assets-log/"
}

# Bucket Versioning
resource "aws_s3_bucket_versioning" "input_assets_bucket_versioning" {
  bucket = aws_s3_bucket.input_assets_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "processed_assets_bucket_versioning" {
  bucket = aws_s3_bucket.processed_assets_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "input_assets_bucket_lifecycle" {
  bucket = aws_s3_bucket.input_assets_bucket.bucket

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "processed_assets_bucket_lifecycle" {
  bucket = aws_s3_bucket.processed_assets_bucket.bucket

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# Bucket Server-Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "input_assets_bucket_encryption" {
  bucket = aws_s3_bucket.input_assets_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_assets_bucket_encryption" {
  bucket = aws_s3_bucket.processed_assets_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
