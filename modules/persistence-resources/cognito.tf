resource "aws_cognito_user_pool" "merged_api" {
  name                     = local.cognito.user_pool_name
  alias_attributes         = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_uppercase = true
    require_symbols   = true
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
  tags = local.combined_tags
}

resource "random_uuid" "merged_api" {
}

resource "aws_cognito_user_pool_domain" "merged_api" {
  domain       = random_uuid.merged_api.result
  user_pool_id = aws_cognito_user_pool.merged_api.id
}

resource "aws_cognito_user_pool_client" "merged_api" {
  name            = local.cognito.user_pool_client_name
  user_pool_id    = aws_cognito_user_pool.merged_api.id
  generate_secret = false

  explicit_auth_flows          = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_USER_SRP_AUTH"]
  enable_token_revocation      = true
  callback_urls                = [local.cognito.callback_url]
  logout_urls                  = [local.cognito.logout_url]
  allowed_oauth_flows          = ["code", "implicit"]
  allowed_oauth_scopes         = ["email", "phone", "openid", "profile", "aws.cognito.signin.user.admin"]
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_identity_pool" "merged_api" {
  identity_pool_name               = local.cognito.identity_pool_name
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.merged_api.id
    provider_name = aws_cognito_user_pool.merged_api.endpoint
  }
  tags = local.combined_tags
}

resource "aws_cognito_identity_pool_roles_attachment" "merged_api" {
  identity_pool_id = aws_cognito_identity_pool.merged_api.id
  roles = {
    "authenticated" = aws_iam_role.authenticated_cognito.arn
  }
}