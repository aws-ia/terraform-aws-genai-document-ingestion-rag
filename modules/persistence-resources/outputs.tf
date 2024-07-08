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
  value = aws_cognito_user_pool.user_pool.id
}

output "opensearch_domain_mame" {
  value = local.opensearch.domain_name
}
output "open_search_domain_endpoint" {
  value = module.opensearch[*].domain_endpoint
}

output "opensearch_serverless_collection_endpoint" {
  value = aws_opensearchserverless_collection.opensearch_serverless_collection[*].collection_endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_ecr_repository.repository_url
}

output "ecr_repository_id" {
  value = aws_ecr_repository.app_ecr_repository.id
}
