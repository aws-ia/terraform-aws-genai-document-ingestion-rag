variables {
  solution_prefix = "test-prefix"
  cognito_user_pool_id = "test-user-pool-id"
  ecr_repository_id = "test-ecr-repo"
  lambda_summarization_input_validation_prop = {
    image_tag = "test-image-tag"
    src_path = "./test-path"
    subnet_ids = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
  }
  lambda_summarization_doc_reader_prop = {
    image_tag = "test-image-tag"
    src_path = "./test-path"
    subnet_ids = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
  }
  lambda_summarization_generator_prop = {
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
  tags = {}
  merged_api_arn = ""
  merged_api_url = ""
  container_platform = "linux/amd64" # "linux/arm64"
  cloudwatch_log_group_retention = "365"
  lambda_reserved_concurrency = 10
}

run "verify_summarization_module" {
  module {
    source = "../../../../modules/summarization"
  }
  command = plan

  assert {
    condition     = aws_appsync_graphql_api.summarization_api.name == "${var.solution_prefix}-summarization-api"
    error_message = "AppSync GraphQL API name is incorrect"
  }

  assert {
    condition     = aws_appsync_graphql_api.summarization_api.authentication_type == "AMAZON_COGNITO_USER_POOLS"
    error_message = "AppSync GraphQL API authentication type is incorrect"
  }

  assert {
    condition     = aws_appsync_datasource.summarization_api.type == "AMAZON_EVENTBRIDGE"
    error_message = "AppSync Datasource type is incorrect"
  }

  assert {
    condition     = aws_lambda_function.summarization_input_validation.function_name == "${var.solution_prefix}-${var.lambda_summarization_input_validation_prop.image_tag}"
    error_message = "Summarization Input Validation Lambda function name is incorrect"
  }

  assert {
    condition     = aws_lambda_function.summarization_doc_reader.function_name == "${var.solution_prefix}-${var.lambda_summarization_doc_reader_prop.image_tag}"
    error_message = "Summarization Doc Reader Lambda function name is incorrect"
  }

  assert {
    condition     = aws_lambda_function.summarization_generator.function_name == "${var.solution_prefix}-${var.lambda_summarization_generator_prop.image_tag}"
    error_message = "Summarization Generator Lambda function name is incorrect"
  }

  assert {
    condition     = aws_sfn_state_machine.summarization_sm.name == "${var.solution_prefix}-summarization-sm"
    error_message = "Step Function state machine name is incorrect"
  }

  assert {
    condition     = aws_kms_key.summarization.enable_key_rotation == true
    error_message = "KMS key rotation is not enabled"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.summarization.name == "${var.solution_prefix}-summarization-event-bus"
    error_message = "CloudWatch Event Rule name is incorrect"
  }

  assert {
    condition     = aws_sqs_queue.summarization_sm_dlq.name == "${var.solution_prefix}-summarization-sm"
    error_message = "SQS DLQ name is incorrect"
  }

  assert {
    condition     = aws_iam_role.summarization_api_log.name == "${var.solution_prefix}-summarization-api-log"
    error_message = "IAM role for AppSync API logging is incorrect"
  }

  assert {
    condition     = aws_cloudwatch_log_group.summarization_api.retention_in_days == 365
    error_message = "CloudWatch Log Group retention period is incorrect"
  }

  assert {
    condition     = aws_lambda_function.summarization_input_validation.reserved_concurrent_executions == 10
    error_message = "Lambda reserved concurrency is incorrect"
  }
}