resource "aws_appsync_graphql_api" "question_answering_graphql_api" {
  name         = "${var.app_prefix}-questionAnsweringGraphqlApi"
  schema       = file("${path.module}/schema.graphql")
  xray_enabled = true
  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.qa_construct_role.arn
    field_log_level          = "ERROR"
  }
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config {
    aws_region = data.aws_region.current_region.name
    default_action = "DENY"
    user_pool_id   = var.cognito_user_pool_id
  }
}

resource "aws_appsync_datasource" "job_status_data_source" {
  api_id           = aws_appsync_graphql_api.question_answering_graphql_api.id
  name             = "_${var.app_prefix}_job_status_data_source"
  service_role_arn = aws_iam_role.job_status_data_source_role.arn
  type             = "NONE"
}
resource "aws_appsync_resolver" "job_status_resolver" {
  api_id      = aws_appsync_graphql_api.question_answering_graphql_api.id
  field       = "updateQAJobStatus"
  type        = "Mutation"
  data_source = aws_appsync_datasource.job_status_data_source.name

  request_template = <<EOF
  {
    "version": "2017-02-28",
    "payload": $util.toJson($context.args)
  }
EOF

  response_template = <<EOF
  #if($ctx.result.statusCode == 200)
    $util.toJson($context.result)
  #else
    $utils.appendError($ctx.result.body, $ctx.result.statusCode)
  #end
EOF

  caching_config {
    caching_keys = [
      "$context.identity.sub",
      "$context.arguments.id",
    ]
    ttl = 60
  }
}

resource "aws_appsync_datasource" "event_bridge_datasource" {
  api_id = aws_appsync_graphql_api.question_answering_graphql_api.id
  name   = "_${var.app_prefix}_question_answering_event_bridge_data_source"
  type   = "AMAZON_EVENTBRIDGE"
  service_role_arn = aws_iam_role.qa_construct_role.arn

  event_bridge_config {
    event_bus_arn = aws_cloudwatch_event_bus.question_answering_event_bus.arn
  }
}
