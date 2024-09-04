output "access_logs_bucket_name" {
  value = aws_s3_bucket.access_logs.bucket
}
output "access_logs_bucket_arn" {
  value = aws_s3_bucket.access_logs.arn
}

output "input_assets_bucket_arn" {
  value = aws_s3_bucket.input_assets.arn
}
output "input_assets_bucket_name" {
  value = aws_s3_bucket.input_assets.bucket
}

output "processed_assets_bucket_name" {
  value = aws_s3_bucket.processed_assets.bucket
}
output "processed_assets_bucket_arn" {
  value = aws_s3_bucket.processed_assets.arn
}
output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.merged_api.id
}

output "opensearch_domain_mame" {
  value = local.opensearch.domain_name
}
output "opensearch_domain_endpoint" {
  value = module.opensearch[*].domain_endpoint
}

output "opensearch_domain_arn" {
  value = module.opensearch[*].domain_arn
}

output "opensearch_serverless_collection_name" {
  value = local.opensearch_serverless.collection_name
}

output "opensearch_serverless_collection_endpoint" {
  value = aws_opensearchserverless_collection.opensearch_serverless_collection[*].collection_endpoint
}

output "opensearch_serverless_arn" {
  value = aws_opensearchserverless_collection.opensearch_serverless_collection[*].arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_ecr_repository.repository_url
}

output "ecr_repository_id" {
  value = aws_ecr_repository.app_ecr_repository.id
}

output "merged_api_arn" {
  value = data.aws_cloudformation_export.merged_api_arn.value
}

output "merged_api_id" {
  value = data.aws_cloudformation_export.merged_api_id.value
}

output "merged_api_url" {
  value = data.aws_cloudformation_export.merged_api_url.value
}

output "cognito_user_client_secret" {
  value = aws_secretsmanager_secret.cognito_user_client_secret.arn
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.merged_api.domain #.value?

}

output "client_id" {
  value = aws_cognito_user_pool_client.merged_api.id

}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.merged_api.id
}

output "client_name" {
  value = aws_cognito_user_pool_client.merged_api.name

}

output "authenticated_role" {
  value = aws_iam_role.authenticated_cognito.arn
}

output "region" {
  value = data.aws_region.current
}