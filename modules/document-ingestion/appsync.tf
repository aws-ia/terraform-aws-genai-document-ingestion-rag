resource "aws_appsync_graphql_api" "ingestion_api" {
  name                = local.graphql.ingestion_api.name
  schema              = file("${path.module}/templates/document_ingestion_schema.graphql")
  xray_enabled        = true
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  user_pool_config {
    aws_region     = data.aws_region.current.name
    default_action = "ALLOW"
    user_pool_id   = var.cognito_user_pool_id
  }

  additional_authentication_provider {
    authentication_type = "AWS_IAM"
  }

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.ingestion_api_log.arn
    field_log_level          = local.graphql.ingestion_api.field_log_level
  }

  tags = local.combined_tags
  #checkov:skip=CKV2_AWS_33:WAF is not required for demonstration purpose
}

resource "aws_appsync_datasource" "ingestion_api" {
  api_id           = aws_appsync_graphql_api.ingestion_api.id
  name             = local.graphql.ingestion_api.event_bridge_datasource_name
  type             = "AMAZON_EVENTBRIDGE"
  service_role_arn = aws_iam_role.ingestion_api_datasource.arn

  event_bridge_config {
    event_bus_arn = awscc_events_event_bus.ingestion.arn
  }
}

# TODO: move to templatefile
resource "aws_appsync_resolver" "ingestion_api" {
  api_id      = aws_appsync_graphql_api.ingestion_api.id
  type        = "Mutation"
  field       = "ingestDocuments"
  data_source = aws_appsync_datasource.ingestion_api.name

  request_template  = <<EOF
    {
      "version": "2018-05-29",
      "operation": "PutEvents",
      "events": [{
        "source": "ingestion",
        "detail": {
            "ingestioninput": $util.toJson($ctx.arguments.ingestioninput),
        },
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