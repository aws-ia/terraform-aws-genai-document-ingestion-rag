############################################################################################################
# IAM Role for AppSync Merged API
############################################################################################################
resource "aws_iam_role" "merged_api" {
  name = "${local.graphql.merged_api.name}-merged-appsync"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "merged_api" {
  name   = local.graphql.merged_api.name
  role   = aws_iam_role.merged_api.id
  policy = data.aws_iam_policy_document.merged_api.json
}

############################################################################################################
# IAM Role for Cognito Identity Pool
############################################################################################################
resource "aws_iam_role" "authenticated_cognito" {
  name = "${local.cognito.identity_pool_name}-cognito-identity"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.merged_api.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "authenticated_cognito" {
  name   = local.cognito.identity_pool_name
  role   = aws_iam_role.authenticated_cognito.id
  policy = data.aws_iam_policy_document.authenticated_cognito.json
}
