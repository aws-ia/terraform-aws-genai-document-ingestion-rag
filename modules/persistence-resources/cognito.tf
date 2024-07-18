resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.bucket_prefix}-cognito_user_pool"
  alias_attributes = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_uppercase = true
    require_symbols   = false
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  lifecycle {
    ignore_changes = [
      password_policy,
      schema
    ]
  }
}

resource "aws_cognito_user_pool_client" "cognito_client" {
  name         = "CognitoClient"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = true

  callback_urls = [var.client_url]
  logout_urls   = [var.client_url]

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
}

# Cognito Identity Pool
resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "IdentityPool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognito_client.id
    provider_name           = aws_cognito_user_pool.user_pool.endpoint
    server_side_token_check = false
  }
}
