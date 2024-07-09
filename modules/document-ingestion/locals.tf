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

  lambda = {
    ingestion_input_validation = {
      name                     = "${var.solution_prefix}-${var.lambda_ingestion_input_validation_prop.image_tag}"
      docker_image_tag         = var.lambda_ingestion_input_validation_prop.image_tag
      source_path              = var.lambda_ingestion_input_validation_prop.src_path
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_ingestion_input_validation_prop.image_tag}-log"
      timeout                  = 600
      environment = {
        variables = {
          GRAPHQL_URL = local.graph_ql_url
        }
      }
    }

    file_transformer = {
      name                     = "${var.solution_prefix}-${var.lambda_file_transformer_prop.image_tag}"
      docker_image_tag         = var.lambda_file_transformer_prop.image_tag
      source_path              = var.lambda_file_transformer_prop.src_path
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_file_transformer_prop.image_tag}-log"
      timeout                  = 600
      environment = {
        variables = {
          INPUT_BUCKET  = var.input_assets_bucket_prop.bucket_name
          OUTPUT_BUCKET = var.processed_assets_bucket_prop.bucket_name
          GRAPHQL_URL   = local.graph_ql_url
        }
      }
    }

    embeddings_job = {
      name                     = "${var.solution_prefix}-${var.lambda_embeddings_job_prop.image_tag}"
      docker_image_tag         = var.lambda_embeddings_job_prop.image_tag
      source_path              = var.lambda_embeddings_job_prop.src_path
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_embeddings_job_prop.image_tag}-log"
      timeout                  = 600
      environment = {
        variables = {
          INPUT_BUCKET  = var.input_assets_bucket_prop.bucket_name
          OUTPUT_BUCKET = var.processed_assets_bucket_prop.bucket_name
          GRAPHQL_URL   = local.graph_ql_url
          OPENSEARCH_DOMAIN_ENDPOINT = local.selected_open_search_endpoint
          OPENSEARCH_INDEX           = var.existing_open_search_index_name
          OPENSEARCH_SECRET_ID       = var.open_search_secret
        }
      }
    }
  }

  graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.ingestion_api.uris["GRAPHQL"] : var.merged_api_url

  # use_serverless_endpoint = length(var.existing_open_search_domain_endpoint) == 0
  # selected_open_search_endpoint = local.use_serverless_endpoint ? var.opensearch_serverless_collection_endpoint[0] : var.existing_open_search_domain_endpoint[0]
  # reate_opensearch_secret_policy = var.open_search_secret == "NONE"
  # ingestion_input_validation_lambda_image_name = "ingestion_input_validation"
  # s3_file_transformer_lambda_image_name = "s3_file_transformer"
  # embeddings_job_lambda_image_name = "embeddings_job"


}
