resource "aws_appsync_graphql_api" "summarization_graphql_api" {
  name = "${var.app_prefix}summarization_graphql_api"
  schema = file("${path.module}/schema.graphql")

  xray_enabled = true

  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config {
    aws_region = data.aws_region.current_region.name
    default_action = "ALLOW"
    user_pool_id   = var.cognito_user_pool_id
  }
  additional_authentication_provider {
    authentication_type = "AWS_IAM"
  }

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.summarization_appsync_logs_role.arn
    field_log_level          = "ALL"
  }
}

resource "aws_appsync_datasource" "summary_status_datasource" {
  api_id           = aws_appsync_graphql_api.summarization_graphql_api.id
  name             = "_${var.app_prefix}_summmary_status_data_source"
  type             = "NONE"
  service_role_arn = aws_iam_role.summarization_construct_role.arn
}

resource "aws_appsync_resolver" "summary_response_resolver" {
  api_id      = aws_appsync_graphql_api.summarization_graphql_api.id
  type        = "Mutation"
  field       = "updateSummaryJobStatus"
  data_source = aws_appsync_datasource.summary_status_datasource.name

  request_template  = <<EOF
    {
      "version": "2017-02-28",
      "payload": $util.toJson($context.args)
    }
  EOF
  response_template = <<EOF
    $util.toJson($context.result)
  EOF
}

resource "aws_appsync_datasource" "event_bridge_datasource" {
  api_id           = aws_appsync_graphql_api.summarization_graphql_api.id
  name             = "_${var.app_prefix}_summarisation_event_bredge_data_source"
  service_role_arn = aws_iam_role.summarization_construct_role.arn
  type             = "AMAZON_EVENTBRIDGE"

  event_bridge_config {
    event_bus_arn = aws_cloudwatch_event_bus.ingestion_event_bus.arn
  }
}

resource "aws_appsync_resolver" "generate_summary" {
  api_id              = aws_appsync_graphql_api.summarization_graphql_api.id
  type                = "Mutation"
  field               = "generateSummary"
  data_source         = aws_appsync_datasource.event_bridge_datasource.name

  request_template    = <<EOF
    {
      "version": "2018-05-29",
      "operation": "PutEvents",
      "events": [{
        "source": "summary",
        "detail": {
            "summaryInput": $util.toJson($ctx.arguments.summaryInput),
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

