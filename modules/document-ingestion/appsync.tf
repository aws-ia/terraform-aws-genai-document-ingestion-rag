# TODO: need to connect to a function
resource "aws_appsync_graphql_api" "ingestion_api" {
  name                = local.graphql.ingestion_api.name
  schema              = file("${path.module}/templates/schema.graphql")
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
    field_log_level          = "ALL"
  }

  tags = local.combined_tags
}

resource "aws_appsync_datasource" "ingestion_api" {
  api_id           = aws_appsync_graphql_api.ingestion_api.id
  name             = local.graphql.ingestion_api.event_bridge_datasource_name
  type             = "AMAZON_EVENTBRIDGE"
  service_role_arn = aws_iam_role.ingestion_api_datasource.arn

  event_bridge_config {
    event_bus_arn = aws_cloudwatch_event_bus.ingestion.arn
  }
}

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

#TODO: migrate to resource: https://github.com/hashicorp/terraform-provider-aws/issues/33148
resource "aws_cloudformation_stack" "merge_ingestion_api" {
  name = "${local.graphql.ingestion_api.name}-merge"

  parameters = {
    mergedGraphQlApiName = var.merged_api_arn
    sourceGraphQlApiName = aws_appsync_graphql_api.ingestion_api.arn
  }

  template_body = templatefile("${path.module}/templates/appsync_association.yaml.tftpl", {})

  tags = local.combined_tags
}

resource "time_sleep" "wait_merge_ingestion_api" {
  depends_on = [aws_cloudformation_stack.merge_ingestion_api]

  create_duration = "30s"
}