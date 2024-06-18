resource "aws_appsync_graphql_api" "ingestion_graphql_api" {
  name = "${var.app_prefix}ingestionGraphqlApi"
  schema = file("${path.module}/schema.graphql")
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config {
      aws_region = data.aws_region.current_region.name
      default_action = "DENY"
      user_pool_id   = var.cognito_user_pool_id
  }
  xray_enabled = true
  log_config {
    field_log_level = "ALL"
    cloudwatch_logs_role_arn = aws_iam_role.appsync_logs_role.arn
  }
}

resource "aws_appsync_datasource" "ingestion_event_bridge_datasource" {
  api_id = aws_appsync_graphql_api.ingestion_graphql_api.id
  name   = "_${var.app_prefix}_ingestionEventBridgeDataSource"
  type   = "AMAZON_EVENTBRIDGE"
  service_role_arn = aws_iam_role.ingestion_construct_role.arn
  event_bridge_config {
    event_bus_arn = aws_cloudwatch_event_bus.ingestion_event_bus.arn
  }
}

resource "aws_appsync_resolver" "ingest_document_resolver" {
  api_id      = aws_appsync_graphql_api.ingestion_graphql_api.id
  type        = "Mutation"
  field       = "ingestDocuments"
  data_source = aws_appsync_datasource.ingestion_event_bridge_datasource.name
  request_template = <<EOF
    {
      "version": "2018-05-29",
      "operation": "PutEvents",
      "events": [{
        "source": "ingestion",
        "detail": $util.toJson($context.arguments),
        "detailType": "genAIdemo"
      }]
    }
  EOF
  response_template = <<EOF
    #if($ctx.error)
      $util.error($ctx.error.message, $ctx.error.type, $ctx.result)
    #end
    $util.toJson($ctx.result)
  EOF
}
