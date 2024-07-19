resource "aws_appsync_graphql_api" "question_answering_api" {
  name                = local.graphql.question_answering_api.name
  schema              = file("${path.module}/templates/question_answering_schema.graphql")
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
    cloudwatch_logs_role_arn = aws_iam_role.question_answering_api_log.arn
    field_log_level          = local.graphql.question_answering_api.field_log_level
  }

  tags = local.combined_tags
}

resource "aws_appsync_datasource" "job_status" {
  api_id = aws_appsync_graphql_api.question_answering_api.id
  name   = local.graphql.question_answering_api.job_status_datasource_name
  type   = "NONE"
}

resource "aws_appsync_resolver" "job_status" {
  api_id           = aws_appsync_graphql_api.question_answering_api.id
  type             = "Mutation"
  field            = "updateQAJobStatus"
  data_source      = aws_appsync_datasource.job_status.name
  request_template = <<EOF
    {
        "version": "2017-02-28",
        "payload": $util.toJson($context.args)
    }
  EOF

  response_template = <<EOF
    $util.toJson($context.result)
  EOF
}

# resource "aws_appsync_datasource" "event_bridge_datasource" {
#   api_id           = aws_appsync_graphql_api.question_answering_graphql_api.id
#   name             = "_${var.app_prefix}_question_answering_event_bridge_data_source"
#   type             = "AMAZON_EVENTBRIDGE"
#   service_role_arn = aws_iam_role.qa_construct_role.arn

#   event_bridge_config {
#     event_bus_arn = aws_cloudwatch_event_bus.question_answering_event_bus.arn
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_appsync_resolver" "question_answering_resolver" {
#   api_id      = aws_appsync_graphql_api.question_answering_graphql_api.id
#   type        = "Mutation"
#   field       = "postQuestion"
#   data_source = aws_appsync_datasource.event_bridge_datasource.name

#   request_template = <<EOF
#   {
#       "version": "2018-05-29",
#       "operation": "PutEvents",
#       "events": [{
#           "source": "questionanswering",
#           "detail": {
#             "filename": $util.toJson($ctx.arguments.filename),
#             "jobid": $util.toJson($ctx.arguments.jobid),
#             "jobstatus": $util.toJson($ctx.arguments.jobid),
#             "max_docs": $util.toJson($ctx.arguments.jobid),
#             "question": $util.toJson($ctx.arguments.jobid),
#             "responseGenerationMethod": $util.toJson($ctx.arguments.jobid),
#             "streaming": $util.toJson($ctx.arguments.jobid),
#             "verbose": $util.toJson($ctx.arguments.jobid)
#           },
#           "detailType": "genAIdemo"
#       }]
#   }
#   EOF

#   response_template = <<EOF
#   #if($ctx.error)
#       $util.error($ctx.error.message, $ctx.error.type, $ctx.result)
#   #end
#   $util.toJson($ctx.result)
#   EOF
# }
