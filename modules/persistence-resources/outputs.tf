output "access_logs_bucket_id" {
  value = aws_s3_bucket.access_logs_bucket.id
}
output "access_logs_bucket_arn" {
  value = aws_s3_bucket.access_logs_bucket.arn
}

output "input_assets_bucket_id" {
  value = aws_s3_bucket.input_assets_bucket.id
}
output "input_assets_bucket_arn" {
  value = aws_s3_bucket.input_assets_bucket.arn
}
output "input_assets_bucket_name" {
  value = aws_s3_bucket.input_assets_bucket.bucket
}

output "processed_assets_bucket_id" {
  value = aws_s3_bucket.processed_assets_bucket.id
}
output "processed_assets_bucket_arn" {
  value = aws_s3_bucket.processed_assets_bucket.arn
}
output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "existing_opensearch_domain_mame" {
  value = aws_opensearch_domain.opensearch_domain[*].domain_name
}
output "existing_open_search_domain_endpoint" {
  value = aws_opensearch_domain.opensearch_domain[*].endpoint
}

output "opensearch_serverless_collection_endpoint" {
  value = aws_opensearchserverless_collection.opensearch_serverless_collection[*].collection_endpoint
}
