locals {
  update_graphql_api_id                     = var.existing_merged_api_id != "" ? var.existing_merged_api_id : aws_appsync_graphql_api.summarization_graphql_api.id
  summary_input_validator_lambda_image_name = "summary_input_validator"
  document_reader_lambda_image_name         = "summary_document_reader"
  generate_summary_lambda_image_name        = "summary_generator_lambda"
  summary_chain_type                        = var.summary_chain_type == "" ? "stuff" : var.summary_chain_type

  graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.summarization_graphql_api.uris["GRAPHQL"] : var.merged_api_url
}
