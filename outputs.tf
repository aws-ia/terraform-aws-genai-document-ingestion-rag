output "cognito_user_client_secret" {
  description = "ARN of the AWS Secrets Manager secret for Cognito client secret key"
  value       = module.persistence_resources.cognito_user_client_secret
}
