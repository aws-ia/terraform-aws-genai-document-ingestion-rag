variables {
  solution_prefix = "test-prefix"
  cognito_user_pool_id = "test-user-pool-id"
  ecr_repository_id = "test-ecr-repo"
  lambda_ingestion_input_validation_prop = {
    image_tag = "test-image-tag"
    src_path = "./test-path"
    subnet_ids = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
  }
  lambda_file_transformer_prop = {
    image_tag = "test-image-tag"
    src_path = "./test-path"
    subnet_ids = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
  }
  lambda_embeddings_job_prop = {
    image_tag = "test-image-tag"
    src_path = "./test-path"
    subnet_ids = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
  }
  input_assets_bucket_prop = {
    bucket_name = "test-input-bucket"
    bucket_arn = "arn:aws:s3:::test-input-bucket"
  }
  processed_assets_bucket_prop = {
    bucket_name = "test-processed-bucket"
    bucket_arn = "arn:aws:s3:::test-processed-bucket"
  }
  opensearch_prop = {
    type = "test-type"
    endpoint = "test-endpoint"
    index_name = "test-index"
    secret = "test-secret"
  }
  tags = {}
  merged_api_arn = ""
  merged_api_url = ""
  container_platform = "linux/arm64"
  cloudwatch_log_group_retention = "365"
  lambda_reserved_concurrency = 10
}

run "verify_document_ingestion_module" {
  module {
    source = "../../../../modules/document-ingestion"
  }
  command = plan

  assert {
    condition     = aws_appsync_graphql_api.ingestion_api.name == "${var.solution_prefix}-ingestion-api"
    error_message = "AppSync GraphQL API name is incorrect"
  }

  assert {
    condition     = aws_appsync_graphql_api.ingestion_api.authentication_type == "AMAZON_COGNITO_USER_POOLS"
    error_message = "AppSync GraphQL API authentication type is incorrect"
  }

  assert {
    condition     = aws_appsync_datasource.ingestion_api.type == "AMAZON_EVENTBRIDGE"
    error_message = "AppSync Datasource type is incorrect"
  }

  assert {
    condition     = aws_lambda_function.ingestion_input_validation.function_name == "${var.solution_prefix}-${var.lambda_ingestion_input_validation_prop.image_tag}"
    error_message = "Ingestion Input Validation Lambda function name is incorrect"
  }

  assert {
    condition     = aws_lambda_function.file_transformer.function_name == "${var.solution_prefix}-${var.lambda_file_transformer_prop.image_tag}"
    error_message = "File Transformer Lambda function name is incorrect"
  }

  assert {
    condition     = aws_lambda_function.embeddings_job.function_name == "${var.solution_prefix}-${var.lambda_embeddings_job_prop.image_tag}"
    error_message = "Embeddings Job Lambda function name is incorrect"
  }

  assert {
    condition     = aws_sfn_state_machine.ingestion_sm.name == "${var.solution_prefix}-ingestion-sm"
    error_message = "Step Function state machine name is incorrect"
  }

  assert {
    condition     = aws_kms_key.ingestion.enable_key_rotation == true
    error_message = "KMS key rotation is not enabled"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.ingestion.name == "${var.solution_prefix}-ingestion-event-bus"
    error_message = "CloudWatch Event Rule name is incorrect"
  }
}
