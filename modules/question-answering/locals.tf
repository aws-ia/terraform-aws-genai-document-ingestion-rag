locals {
  use_serverless_endpoint              = length(var.existing_open_search_domain_endpoint) == 0
  selected_open_search_endpoint        = local.use_serverless_endpoint ? var.opensearch_serverless_collection_endpoint[0] : var.existing_open_search_domain_endpoint[0]
  reate_opensearch_secret_policy       = var.open_search_secret == "NONE"
  question_answering_lambda_image_name = "question_answering"

  graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.question_answering_graphql_api.uris["GRAPHQL"] : var.merged_api_url
}
