# Create an ECR repository
resource "aws_ecr_repository" "question_answering_function" {
  name = "question_answering_function${var.stage}"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = aws_kms_key.ecr_kms_key.arn  # Referencing the KMS key
  }
}

# Manage ECR image versions
resource "aws_ecr_lifecycle_policy" "question_answering_function_policy" {
  repository = aws_ecr_repository.question_answering_function.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_kms_key" "ecr_kms_key" {
  description             = "KMS key for encrypting ECR images"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.question_answering_function_role.arn,
          ]
        }
        Action   = [
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

# Build and push Docker image to ECR
resource "null_resource" "build_and_push_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Build Docker image
      docker build -t ${aws_ecr_repository.question_answering_function.repository_url}:latest .
      # Authenticate Docker with ECR
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.question_answering_function.registry_id}.dkr.ecr.your-region.amazonaws.com
      # Push Docker image to ECR
      docker push ${aws_ecr_repository.question_answering_function.repository_url}:latest
    EOT
  }
}

resource "aws_sqs_queue" "dlq" {
  name = "question_answering_function_dlq"
  sqs_managed_sse_enabled = true
}

resource "aws_signer_signing_profile" "question_answering_profile" {
  name            = "qa_sign_profile"
  platform_id     = "AWSLambda-SHA384-ECDSA"

  signature_validity_period {
    type  = "DAYS"
    value = 365
  }

  tags = {
    Name = "question_answering Profile"
  }
}

resource "aws_lambda_code_signing_config" "question_answering_function" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.question_answering_profile.arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}


# Create Lambda function using Docker image from ECR
resource "aws_lambda_function" "question_answering_function" {
  function_name = "question_answering_function"
  role          = aws_iam_role.question_answering_function_role.arn
  handler       = "not_required_for_containers"
  runtime       = "provided.al2"
  timeout       = 900
  memory_size   = 1024
  image_uri     = "${aws_ecr_repository.question_answering_function.repository_url}:latest"
  vpc_config {
    security_group_ids = [local.security_group_id]
    subnet_ids         = [aws_subnet.private_subnet.id]
  }
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      GRAPHQL_URL                = aws_appsync_graphql_api.question_answering_graphql_api.uris["GRAPHQL"]
      INPUT_BUCKET               = aws_s3_bucket.input_assets_qa_bucket.bucket
      OPENSEARCH_DOMAIN_ENDPOINT = var.existing_opensearch_domain.endpoint
      OPENSEARCH_INDEX           = var.open_search_index_name
      OPENSEARCH_SECRET_ID       = local.secret_id
    }
  }
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  reserved_concurrent_executions = 10
  depends_on = [null_resource.build_and_push_image]
  code_signing_config_arn = aws_lambda_code_signing_config.question_answering_function.arn
  kms_key_arn = aws_kms_key.customer_managed_kms_key.arn
}

resource "aws_lambda_permission" "grant_invoke_lambda" {
  statement_id  = "AllowAppSyncToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering_function.arn
  principal     = "appsync.amazonaws.com"
  source_arn    = aws_appsync_datasource.event_bridge_datasource.arn
}
