#TODO: migrate to resource: https://github.com/hashicorp/terraform-provider-aws/issues/33148
resource "aws_cloudformation_stack" "merged_api" {
  name = local.graphql.merged_api.name

  parameters = {
    graphQlApiName            = local.graphql.merged_api.name
    userPoolId                = aws_cognito_user_pool.merged_api.id
    userPoolAwsRegion         = data.aws_region.current.name
    cloudwatchLogsRoleArn     = aws_iam_role.merged_api.arn
    mergedApiExecutionRoleArn = aws_iam_role.merged_api.arn
  }

  template_body = templatefile("${path.module}/templates/appsync.yaml.tftpl", {
    local_graphql_merged_api_export_id  = local.graphql.merged_api.export_id
    local_graphql_merged_api_export_arn = local.graphql.merged_api.export_arn
    local_graphql_merged_api_export_url = local.graphql.merged_api.export_url
  })

  tags = local.combined_tags
}

resource "time_sleep" "wait_merge_api" {
  depends_on = [aws_cloudformation_stack.merged_api]

  create_duration = "30s"
}