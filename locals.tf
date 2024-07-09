locals {
  solution_prefix = "${var.solution_prefix}-${random_string.solution_prefix.result}"

  use_serverless_opensearch = var.open_search_props.open_search_service_type == "aoss" ? true : false
  use_opensearch = var.open_search_props.open_search_service_type == "es" ? true : false
  # merged_api_id  = trimspace(data.local_file.merged_api_id.content)
  # merged_api_url = trimspace(data.local_file.merged_api_url.content)
}
