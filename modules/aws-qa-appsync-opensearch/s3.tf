# Bucket for storing server access logging
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
    ]
  })
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

resource "aws_kinesis_firehose_delivery_stream" "s3_firehose_stream" {
  name        = "firehose_delivery_stream_to_s3"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.server_access_log_bucket.arn
    buffer_size = 10 // in MBs
    buffer_interval = 300 // in seconds
  }
  server_side_encryption {
     enabled=true #default is false
     key_type = "CUSTOMER_MANAGED_CMK"
     key_arn = aws_kms_key.customer_managed_kms_key.arn
   }
}

resource "aws_s3_bucket" "waf_logs" {
  bucket = "waf-logs-${var.stage}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.customer_managed_kms_key.arn
      }
    }
  }

  lifecycle_rule {
    id      = "log"
    enabled = true
    expiration {
      days = 365
    }
  }

  logging {
    target_bucket = aws_s3_bucket.waf_logs.id
    target_prefix = "log/"
  }

  versioning {
    enabled = true
  }
}

resource "aws_kinesis_firehose_delivery_stream" "waf_logs_stream" {
  name        = "waf-logs-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.waf_logs.arn
    buffer_size = 10 // in MBs
    buffer_interval = 300 // in seconds
  }

  server_side_encryption {
     enabled=true #default is false
     key_type = "CUSTOMER_MANAGED_CMK"
     key_arn = aws_kms_key.customer_managed_kms_key.arn
   }
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs_stream.arn]
  resource_arn            = aws_wafv2_web_acl.appsync_web_acl.arn

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

resource "aws_s3_bucket_notification" "input_assets_qa_bucket_notification" {
  bucket = aws_s3_bucket.input_assets_qa_bucket.id
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
      storage_class = "STANDARD"
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

  lifecycle_rule {
    id      = "log"
    enabled = true

    expiration {
      days = 90
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


resource "aws_s3_bucket_notification" "waf_logs_notification" {
  bucket = aws_s3_bucket.waf_logs.id

  topic {
    topic_arn = aws_sns_topic.s3_bucket_notification_topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}