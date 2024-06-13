# Create an ECR repository
resource "aws_ecr_repository" "question_answering_function" {
  name = "${var.app_prefix}question_answering_function"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = aws_kms_key.ecr_kms_key.arn
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
  policy = data.aws_iam_policy_document.ecr_kms_key.json
}

# Build and push Docker image to ECR
resource "null_resource" "build_and_push_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = aws_ecr_repository.question_answering_function.repository_url
      AWS_REGION     = data.aws_region.current_region.name
    }
    command = "${abspath(path.module)}/../../lambda/aws-qa-appsync-opensearch/question_answering/src/build_push_docker.sh"
  }
}

resource "aws_sqs_queue" "dlq" {
  name = "${var.app_prefix}question_answering_function_dlq"
  sqs_managed_sse_enabled = true
}

resource "aws_signer_signing_profile" "question_answering_profile" {
  name            = "${var.app_prefix}qa_sign_profile"
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
  function_name = "${var.app_prefix}question_answering_function"
  role          = aws_iam_role.question_answering_function_role.arn
  image_uri     = "${aws_ecr_repository.question_answering_function.repository_url}:latest"
  package_type  = "Image"
  vpc_config {
    security_group_ids = var.security_groups_ids
    subnet_ids         = var.subnet_ids
  }
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      GRAPHQL_URL                = aws_appsync_graphql_api.question_answering_graphql_api.uris["GRAPHQL"]
      INPUT_BUCKET               = var.input_assets_bucket_name
      OPENSEARCH_DOMAIN_ENDPOINT = local.selected_open_search_endpoint
      OPENSEARCH_INDEX           = var.existing_open_search_index_name
      OPENSEARCH_SECRET_ID       = var.open_search_secret
    }
  }
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  reserved_concurrent_executions = 10
  depends_on = [null_resource.build_and_push_image]
  kms_key_arn = aws_kms_key.customer_managed_kms_key.arn
}

resource "aws_lambda_permission" "grant_invoke_lambda" {
  statement_id  = "AllowAppSyncToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering_function.arn
  principal     = "appsync.amazonaws.com"
  source_arn    = aws_appsync_datasource.event_bridge_datasource.arn
}

