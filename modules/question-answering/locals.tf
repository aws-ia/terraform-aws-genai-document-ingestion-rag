locals {
  combined_tags = merge(
    var.tags,
    {
      Submodule = "question-answering"
    }
  )

  graphql = {
    question_answering_api = {
      name                       = "${var.solution_prefix}-qa-api"
      cloudwatch_log_role_name   = "${var.solution_prefix}-qa-api-log"
      field_log_level            = "ALL"
      job_status_datasource_name = replace("${var.solution_prefix}-qa-jobstatus-datasource", "-", "_") # must match pattern [_A-Za-z][_0-9A-Za-z]*
    }
  }

  # use_serverless_endpoint              = length(var.existing_open_search_domain_endpoint) == 0
  # selected_open_search_endpoint        = local.use_serverless_endpoint ? var.opensearch_serverless_collection_endpoint[0] : var.existing_open_search_domain_endpoint[0]
  # reate_opensearch_secret_policy       = var.open_search_secret == "NONE"
  # question_answering_lambda_image_name = "question_answering"

  # graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.question_answering_graphql_api.uris["GRAPHQL"] : var.merged_api_url
}
