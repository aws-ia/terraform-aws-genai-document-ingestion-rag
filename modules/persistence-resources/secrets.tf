resource "aws_secretsmanager_secret" "cognito_user_client_secret" {
  name                    = "${var.solution_prefix}-cognito_user_client_secret"
  recovery_window_in_days = 30
  kms_key_id              = aws_kms_alias.persistent_resources.arn
  #checkov:skip=CKV2_AWS_57:client secret rotation is optional for demo
}

resource "aws_secretsmanager_secret_version" "cognito_user_client_secret" {
  secret_id     = aws_secretsmanager_secret.cognito_user_client_secret.id
  secret_string = aws_cognito_user_pool_client.merged_api.client_secret
}
