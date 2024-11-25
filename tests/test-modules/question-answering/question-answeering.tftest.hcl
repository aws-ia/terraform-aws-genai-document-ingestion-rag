variables {
  solution_prefix = "test-prefix"
  cognito_user_pool_id = "test-user-pool-id"
  ecr_repository_id = "test-ecr-repo"
  lambda_question_answering_prop = {
    image_tag = "test-image-tag"
    src_path = "./test-path"
    subnet_ids = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
  }
  processed_assets_bucket_prop = {
    bucket_name = "test-processed-bucket"
    bucket_arn = "arn:aws:s3:::test-processed-bucket"
  }
  opensearch_prop = {
    type = "es"
    endpoint = "test-endpoint"
    index_name = "test-index"
    secret = "test-secret"
    arn = "arn:aws:es:us-west-2:123456789012:domain/test-domain"
  }
  tags = {}
  merged_api_arn = ""
  merged_api_url = ""
  container_platform = "linux/amd64" # "linux/arm64"
  cloudwatch_log_group_retention = "365"
  lambda_reserved_concurrency = 10
}

run "verify_question_answering_module" {
  module {
    source = "../../../../modules/question-answering"
  }
  command = plan

  assert {
    condition     = aws_appsync_graphql_api.question_answering_api.name == "${var.solution_prefix}-qa-api"
    error_message = "AppSync GraphQL API name is incorrect"
  }

  assert {
    condition     = aws_appsync_graphql_api.question_answering_api.authentication_type == "AMAZON_COGNITO_USER_POOLS"
    error_message = "AppSync GraphQL API authentication type is incorrect"
  }

  assert {
    condition     = aws_appsync_datasource.question_answering_api_event_bridge.type == "AMAZON_EVENTBRIDGE"
    error_message = "AppSync Datasource type is incorrect"
  }

  assert {
    condition     = aws_lambda_function.question_answering.function_name == "${var.solution_prefix}-${var.lambda_question_answering_prop.image_tag}"
    error_message = "Question Answering Lambda function name is incorrect"
  }

  assert {
    condition     = aws_lambda_function.question_answering.package_type == "Image"
    error_message = "Question Answering Lambda package type is incorrect"
  }

  assert {
    condition     = aws_lambda_function.question_answering.timeout == 900
    error_message = "Question Answering Lambda timeout is incorrect"
  }

  assert {
    condition     = aws_lambda_function.question_answering.memory_size == 7076
    error_message = "Question Answering Lambda memory size is incorrect"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.question_answering.name == "${var.solution_prefix}-qa-event-bus"
    error_message = "CloudWatch Event Rule name is incorrect"
  }

  assert {
    condition     = aws_kms_key.question_answering.enable_key_rotation == true
    error_message = "KMS key rotation is not enabled"
  }

  assert {
    condition     = aws_cloudwatch_log_group.question_answering.retention_in_days == 365
    error_message = "CloudWatch Log Group retention period is incorrect"
  }

  assert {
    condition     = aws_lambda_function.question_answering.reserved_concurrent_executions == 10
    error_message = "Lambda reserved concurrency is incorrect"
  }

  assert {
    condition     = contains(aws_iam_role_policy.question_answering.policy, var.processed_assets_bucket_prop.bucket_arn)
    error_message = "IAM policy for Question Answering Lambda does not include the processed assets bucket ARN"
  }

  assert {
    condition     = contains(aws_lambda_function.question_answering.environment[0].variables, "OPENSEARCH_API_NAME")
    error_message = "Lambda environment variables do not include OPENSEARCH_API_NAME"
  }

  assert {
    condition     = aws_appsync_resolver.question_answering_api_event_bridge.type == "Mutation"
    error_message = "AppSync resolver type for event bridge is incorrect"
  }
}