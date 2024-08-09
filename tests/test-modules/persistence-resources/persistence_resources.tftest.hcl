variables {
  solution_prefix = "test-prefix"
  open_search_service_type = "aoss"
  open_search_props = {
    domain_name = "test-domain"
    collection_name = "test-collection"
    engine_version = "OpenSearch_1.0"
    cluster_config = {
      instance_type = "t3.small.search"
    }
    ebs_options = {
      volume_size = 10
    }
    master_user_arn = "arn:aws:iam::123456789012:user/test-user"
    subnet_ids = ["subnet-12345"]
    open_search_vpc_endpoint_id = "vpce-12345"
  }
  tags = {
    Environment = "test"
  }
  force_destroy = true
  target_merge_apis = ["arn:aws:appsync:us-west-2:123456789012:apis/abcdefghijklmnopqrstuvwxyz"]
}

run "verify_persistence_resources_module" {
  module {
    source = "../../../../modules/persistence-resources"
  }
  command = plan

  assert {
    condition     = aws_s3_bucket.access_logs.bucket_prefix == substr("${var.solution_prefix}-access-logs", 0, 62)
    error_message = "Access logs S3 bucket name prefix is incorrect"
  }

  assert {
    condition     = aws_s3_bucket.input_assets.bucket_prefix == substr("${var.solution_prefix}-input-assets", 0, 62)
    error_message = "Input assets S3 bucket name prefix is incorrect"
  }

  assert {
    condition     = aws_s3_bucket.processed_assets.bucket_prefix == substr("${var.solution_prefix}-processed-assets", 0, 62)
    error_message = "Processed assets S3 bucket name prefix is incorrect"
  }

  assert {
    condition     = aws_cognito_user_pool.merged_api.name == var.solution_prefix
    error_message = "Cognito User Pool name is incorrect"
  }

  assert {
    condition     = aws_cognito_user_pool_client.merged_api.name == var.solution_prefix
    error_message = "Cognito User Pool Client name is incorrect"
  }

  assert {
    condition     = aws_cognito_identity_pool.merged_api.identity_pool_name == var.solution_prefix
    error_message = "Cognito Identity Pool name is incorrect"
  }

  assert {
    condition     = aws_ecr_repository.app_ecr_repository.name == var.solution_prefix
    error_message = "ECR repository name is incorrect"
  }

  assert {
    condition     = aws_kms_key.persistent_resources.enable_key_rotation == true
    error_message = "KMS key rotation is not enabled"
  }

  assert {
    condition     = aws_kms_alias.persistent_resources.name == "alias/${var.solution_prefix}-persistent-resources"
    error_message = "KMS key alias is incorrect"
  }

  assert {
    condition     = aws_opensearchserverless_collection.opensearch_serverless_collection[0].name == "${var.solution_prefix}-${var.open_search_props.collection_name}"
    error_message = "OpenSearch Serverless collection name is incorrect"
  }

  assert {
    condition     = aws_iam_role.merged_api.name == "${var.solution_prefix}-merged-api-merged-appsync"
    error_message = "IAM role for AppSync Merged API name is incorrect"
  }

  assert {
    condition     = aws_cloudformation_stack.merged_api.name == "${var.solution_prefix}-merged-api"
    error_message = "CloudFormation stack name for Merged API is incorrect"
  }

  assert {
    condition     = aws_secretsmanager_secret.cognito_user_client_secret.name == "${var.solution_prefix}-cognito_user_client_secret"
    error_message = "Secrets Manager secret name for Cognito User Pool Client is incorrect"
  }
}