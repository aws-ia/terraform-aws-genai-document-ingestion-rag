locals {
  solution_prefix = "${var.solution_prefix}-${random_string.solution_prefix.result}"

  # determine if using opensearch serverless (aoss) or standard opensearch (es)
  opensearch = {
    use_serverless_opensearch = var.open_search_props.open_search_service_type == "aoss" ? true : false
    use_opensearch            = var.open_search_props.open_search_service_type == "es" ? true : false
  }

  # set specific properties for aoss vs es
  temp_opensearch_prop = local.opensearch.use_serverless_opensearch ? {
    name     = module.persistence_resources.opensearch_serverless_collection_name
    endpoint = module.persistence_resources.opensearch_serverless_collection_endpoint[0]
    } : local.opensearch.use_opensearch ? {
    name     = module.persistence_resources.opensearch_domain_mame
    endpoint = module.persistence_resources.open_search_domain_endpoint[0]
  } : {}

  # set common properties for both aoss and es
  final_opensearch_prop = merge(
    local.temp_opensearch_prop,
    {
      type       = var.open_search_props.open_search_service_type
      index_name = var.open_search_props.index_name
      secret     = var.open_search_props.secret
    }
  )
}
