# Bucket for storing server access logging
resource "aws_kms_key" "customer_managed_kms_key" {
  enable_key_rotation = true
}

resource "aws_s3_bucket" "server_access_log_bucket" {
  bucket_prefix = "server-access-log-bucket-${var.stage}"
  force_destroy = false

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.customer_managed_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_sns_topic" "s3_bucket_notification_topic" {
  name = "s3-bucket-notification-topic"
  kms_master_key_id = aws_kms_key.customer_managed_kms_key.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.server_access_log_bucket.id

  topic {
    topic_arn = aws_sns_topic.s3_bucket_notification_topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_replication_configuration" "input_assets_replication" {
  bucket = aws_s3_bucket.input_assets_qa_bucket.id

  role = aws_iam_role.question_answering_function_role.arn

  rule {
    id     = "replicateAll"
    status = "Enabled"
    destination {
      bucket = aws_s3_bucket.input_assets_qa_bucket.arn
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "server_access_replication" {
  bucket = aws_s3_bucket.server_access_log_bucket.id

  role = aws_iam_role.question_answering_function_role.arn

  rule {
    id     = "replicateAll"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.input_assets_qa_bucket.arn
    }
  }
}

resource "aws_s3_bucket_acl" "server_access_log_bucket_acl" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "server_access_log_bucket_encryption" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
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

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_policy" "server_access_log_bucket_policy" {
  bucket = aws_s3_bucket.server_access_log_bucket.id
  policy = data.aws_iam_policy_document.server_access_log_bucket_policy.json
}

# Bucket containing the inputs assets (documents - text format) uploaded by the user
resource "aws_s3_bucket" "input_assets_qa_bucket" {
  bucket = local.bucket_inputs_assets_props_bool ? var.bucket_inputs_assets_props.bucket_name : format("input-asset-qa-bucket%s-%s", var.stage, data.aws_caller_identity.current.account_id)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.customer_managed_kms_key.arn
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.server_access_log_bucket.id
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket_public_access_block" "input_assets_qa_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.input_assets_qa_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "server_access_log_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.server_access_log_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
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

resource "aws_s3_bucket_lifecycle_configuration" "input_assets_qa_bucket_lifecycle" {
  bucket = local.input_assets_bucket_name
  rule {
    id     = "input_assets_qa_bucket"
    status = "Enabled"
    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
