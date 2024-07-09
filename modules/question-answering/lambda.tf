# Build and push Docker image to ECR
resource "null_resource" "build_and_push_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = var.ecr_repository_url
      AWS_REGION     = data.aws_region.current_region.name
      IMAGE_NAME = local.question_answering_lambda_image_name
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
  image_uri     = "${var.ecr_repository_url}:${local.question_answering_lambda_image_name}"
  package_type  = "Image"
  timeout = 300
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      GRAPHQL_URL                = local.graph_ql_url
      INPUT_BUCKET               = var.input_assets_bucket_name
      OPENSEARCH_DOMAIN_ENDPOINT = local.selected_open_search_endpoint
      OPENSEARCH_INDEX           = var.existing_open_search_index_name
      OPENSEARCH_SECRET_ID       = var.open_search_secret
      OPENSEARCH_API_NAME = local.open_search_api_name
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

