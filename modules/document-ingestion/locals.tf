locals {
  use_serverless_endpoint = length(var.existing_open_search_domain_endpoint) == 0
  selected_open_search_endpoint = local.use_serverless_endpoint ? var.opensearch_serverless_collection_endpoint[0] : var.existing_open_search_domain_endpoint[0]
  reate_opensearch_secret_policy = var.open_search_secret == "NONE"
  ingestion_input_validation_lambda_image_name = "ingestion_input_validation"
  s3_file_transformer_lambda_image_name = "s3_file_transformer"
  embeddings_job_lambda_image_name = "embeddings_job"

  graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"] : var.merged_api_url
}
