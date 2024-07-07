resource "aws_cognito_user_pool" "user_pool" {
  name                     = local.cognito.user_pool_name
  alias_attributes         = ["email", "preferred_username"]
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
