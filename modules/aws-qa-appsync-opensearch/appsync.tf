#GraphQL Api
resource "aws_appsync_graphql_api" "question_answering_graphql_api" {
  name     = "questionAnsweringGraphqlApi${var.stage}"
  schema   = file("${path.module}/schema.graphql")
  xray_enabled = var.enable_xray
  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.qa_construct_role.arn
    field_log_level          = "ERROR"
  }
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config {
#    region = data.aws_region.current.name
    default_action = "DENY"
    user_pool_id   = var.cognito_user_pool_id
  }
  additional_authentication_provider {
    authentication_type = "AWS_IAM"
  }
}

output "graphql_api_endpoint" {
  value = local.existing_merged_api_bool ? var.existing_merged_api.url : aws_appsync_graphql_api.question_answering_graphql_api.uris["GRAPHQL"]
}

output "graphql_api_id" {
  value = local.existing_merged_api_bool ? var.existing_merged_api.id : aws_appsync_graphql_api.question_answering_graphql_api.id
}

resource "aws_appsync_datasource" "job_status_data_source" {
  name = "JobStatusDataSource"
  api_id = local.graph_ql_id
  service_role_arn = aws_iam_role.appsync_service_role.arn
  type = "NONE"
}

resource "aws_appsync_resolver" "update_qa_job_status_resolver" {
  api_id   = local.graph_ql_id
  type = "Mutation"
  field = "updateQAJobStatus"
  data_source = aws_appsync_datasource.job_status_data_source.name
  request_template = <<EOT
{
  "version": "2017-02-28",
  "payload": $util.toJson($context.args)
}
EOT

  response_template = "$util.toJson($context.result)"
}

resource "aws_appsync_datasource" "event_bridge_datasource" {
  api_id   = local.graph_ql_id
  name     = "questionAnsweringEventBridgeDataSource${var.stage}"
  type     = "HTTP"

  http_config {
    endpoint = aws_cloudwatch_event_bus.question_answering_event_bus.arn
  }
}

resource "aws_appsync_resolver" "question_answering_resolver" {
  api_id = local.graph_ql_id
  field = "postQuestion"
  type = "Mutation"

  request_template = <<-EOT
    {
        "version": "2018-05-29",
        "operation": "PutEvents",
        "events": [{
            "source": "questionanswering",
            "detail": $util.toJson($context.arguments),
            "detailType": "Question answering"
        }]
    }
  EOT

  response_template = <<-EOT
    #if($ctx.error)
        $util.error($ctx.error.message, $ctx.error.type, $ctx.result)
    #end
    $util.toJson($ctx.result)
  EOT
}
