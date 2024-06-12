resource "aws_s3_bucket" "server_access_log_bucket" {
  bucket = "${var.bucket_prefix}-server-access-log-bucket"
  tags = {
    Name = "server-access-log-bucket-${var.stage}"
  }
}
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnencryptedConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          "arn:aws:s3:::${aws_s3_bucket.server_access_log_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.server_access_log_bucket.bucket}"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "server_access_log_bucket_access_block" {
  bucket = aws_s3_bucket.server_access_log_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_lifecycle_configuration" "server_access_log_bucket" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  rule {
    id      = "server_access_log_bucket"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "server_access_log_bucket" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm  = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "server_access_log_bucket" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# logs
resource "aws_kms_key" "customer_managed_kms_key" {
  enable_key_rotation = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid       = "Allow access for Key Administrators",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket                  = aws_s3_bucket.waf_logs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "waf_logs" {
  #TODO change
  bucket = "waf-logs-dev"
}
resource "aws_s3_bucket_logging" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  target_bucket = aws_s3_bucket.waf_logs.id
  target_prefix = "log/"
}
resource "aws_s3_bucket_versioning" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.customer_managed_kms_key.arn
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "s3_firehose_stream" {
  name        = "firehose_delivery_stream_to_s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.server_access_log_bucket.arn
    buffering_size = 10
    buffering_interval = 300
  }
  server_side_encryption {
    enabled=true #default is false
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn = aws_kms_key.customer_managed_kms_key.arn
  }
}

resource "aws_s3_bucket_replication_configuration" "multi_region_replication" {
  depends_on = [aws_s3_bucket_versioning.waf_logs]
  role   = aws_iam_role.firehose_role.arn
  bucket = aws_s3_bucket.waf_logs.arn

  rule {
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.waf_logs.arn
      storage_class = "STANDARD"
    }
  }
}

# Separate resource for lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "waf_logs_lifecycle" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    id      = "log"
    status = "Enabled"

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "waf_logs_stream" {
  name        = "waf-logs-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.waf_logs.arn
    buffering_size = 10
    buffering_interval = 300
  }

  server_side_encryption {
    enabled=true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn = aws_kms_key.customer_managed_kms_key.arn
  }
}
