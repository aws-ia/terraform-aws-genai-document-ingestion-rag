locals {
  combined_tags = merge(
    var.tags,
    {
      Solution = var.solution_prefix
    }
  )

  graphql = {
    ingestion_api = {
      name                         = "${var.solution_prefix}-ingestion-api"
      cloudwatch_log_role_name     = "${var.solution_prefix}-ingestion-api-log"
      event_bridge_datasource_name = replace("${var.solution_prefix}-ingestion-datasource", "-", "_") # must match pattern [_A-Za-z][_0-9A-Za-z]*
    }
  }

  cloudwatch = {
    ingestion = {
      event_bus_name = "${var.solution_prefix}-ingestion-event-bus"
      log_group_name = "${var.solution_prefix}-ingestion-log-group"
      log_retention  = 90
    }
  }

  # use_serverless_endpoint = length(var.existing_open_search_domain_endpoint) == 0
  # selected_open_search_endpoint = local.use_serverless_endpoint ? var.opensearch_serverless_collection_endpoint[0] : var.existing_open_search_domain_endpoint[0]
  # reate_opensearch_secret_policy = var.open_search_secret == "NONE"
  # ingestion_input_validation_lambda_image_name = "ingestion_input_validation"
  # s3_file_transformer_lambda_image_name = "s3_file_transformer"
  # embeddings_job_lambda_image_name = "embeddings_job"

  # graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"] : var.merged_api_url
}
