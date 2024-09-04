output "cognito_user_client_secret" {
  description = "ARN of the AWS Secrets Manager secret for Cognito client secret key"
  value       = module.persistence_resources.cognito_user_client_secret
}

output "cognito_domain" {
  description = "The Cognito Domain."
  value       = module.persistence_resources.cognito_domain
}

output "region" {
  description = "The AWS Region."
  value       = module.persistence_resources.region
}

output "user_pool_id" {
  description = "The User Pool ID."
  value       = module.persistence_resources.cognito_user_pool_id
}

output "client_id" {
  description = "The Cognito Client ID."
  value       = module.persistence_resources.client_id
}

output "identity_pool_id" {
  description = "The Cognito Identity Pool ID."
  value       = module.persistence_resources.identity_pool_id
}

output "authenticated_role_arn" {
  description = "The Authenticated Role ARN."
  value       = module.persistence_resources.authenticated_role
}

output "graphql_endpoint" {
  description = "The GraphQL Endpoint."
  value       = module.persistence_resources.merged_api_url
} 

output "s3_input_bucket" {
  description = "The S3 Input Bucket."
  value       = module.persistence_resources.input_assets_bucket_name
}

output "s3_processed_bucket" {
  description = "The S3 processed bucket."
  value       = module.persistence_resources.processed_assets_bucket_name
}

output "client_name" {
  description = "The Cognito Client Name."
  value       = module.persistence_resources.client_name
}
