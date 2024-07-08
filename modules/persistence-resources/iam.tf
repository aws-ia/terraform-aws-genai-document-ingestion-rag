############################################################################################################
# IAM Role for AppSync Merged API
############################################################################################################
resource "aws_iam_role" "merged_api" {
  name = local.graphql.merged_api.name

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
  name = local.graphql.merged_api.name
  role = aws_iam_role.merged_api.id
  policy = data.aws_iam_policy_document.merged_api.json
}
