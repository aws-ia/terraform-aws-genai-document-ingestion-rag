resource "aws_appsync_graphql_api" "summarization_api" {
  name                = local.graphql.summarization_api.name
  schema              = file("${path.module}/templates/summarization_schema.graphql")
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
    cloudwatch_logs_role_arn = aws_iam_role.summarization_api_log.arn
    field_log_level          = "ALL"
  }

  tags = local.combined_tags
}

resource "aws_appsync_datasource" "summarization_api" {
  api_id           = aws_appsync_graphql_api.summarization_api.id
  name             = local.graphql.summarization_api.event_bridge_datasource_name
  type             = "AMAZON_EVENTBRIDGE"
  service_role_arn = aws_iam_role.summarization_api_datasource.arn

  event_bridge_config {
    event_bus_arn = aws_cloudwatch_event_bus.summarization.arn
  }
}

resource "aws_appsync_resolver" "summarization_api" {
  api_id      = aws_appsync_graphql_api.summarization_api.id
  type        = "Mutation"
  field       = "generateSummary"
  data_source = aws_appsync_datasource.summarization_api.name

  request_template  = <<EOF
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

resource "aws_appsync_datasource" "summarization_status" {
  api_id = aws_appsync_graphql_api.summarization_api.id
  name   = local.graphql.summarization_api.status_datasource_name
  type   = "NONE"
}

resource "aws_appsync_resolver" "summarization_status" {
  api_id      = aws_appsync_graphql_api.summarization_api.id
  type        = "Mutation"
  field       = "updateSummaryJobStatus"
  data_source = aws_appsync_datasource.summarization_status.name

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