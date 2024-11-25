output "cognito_user_client_secret" {
  description = "ARN of the AWS Secrets Manager secret for Cognito client secret key."
  value       = module.persistence_resources.cognito_user_client_secret
}

output "cognito_domain" {
  description = "The Cognito domain."
  value       = "https://${module.persistence_resources.cognito_domain}.auth.${module.persistence_resources.region.id}.amazoncognito.com"
}

output "region" {
  description = "The AWS region."
  value       = module.persistence_resources.region.id
}

output "user_pool_id" {
  description = "The Cognito user pool ID."
  value       = module.persistence_resources.cognito_user_pool_id
}

output "client_id" {
  description = "The Cognito client ID."
  value       = module.persistence_resources.client_id
}

output "identity_pool_id" {
  description = "The Cognito identity pool ID."
  value       = module.persistence_resources.identity_pool_id
}

output "authenticated_role_arn" {
  description = "The authenticated role ARN."
  value       = module.persistence_resources.authenticated_role
}

output "graphql_endpoint" {
  description = "The GraphQL endpoint."
  value       = module.persistence_resources.merged_api_url
}

output "s3_input_bucket" {
  description = "The S3 input bucket."
  value       = module.persistence_resources.input_assets_bucket_name
}

output "s3_processed_bucket" {
  description = "The S3 processed bucket."
  value       = module.persistence_resources.processed_assets_bucket_name
}

output "client_name" {
  description = "The Cognito client name."
  value       = module.persistence_resources.client_name
}
