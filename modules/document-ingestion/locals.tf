locals {
  combined_tags = merge(
    var.tags,
    {
      Submodule = "document-ingestion"
    }
  )

  graphql = {
    ingestion_api = {
      name                         = "${var.solution_prefix}-ingestion-api"
      cloudwatch_log_role_name     = "${var.solution_prefix}-ingestion-api-log"
      field_log_level              = "ALL"
      event_bridge_datasource_name = replace("${var.solution_prefix}-ingestion-datasource", "-", "_") # must match pattern [_A-Za-z][_0-9A-Za-z]*
    }
  }

  cloudwatch = {
    ingestion = {
      event_bus_name = "${var.solution_prefix}-ingestion-event-bus"
      log_group_name = "/${var.solution_prefix}/${var.solution_prefix}-ingestion"
      log_retention  = 90
    }
    ingestion_sm = {
      event_bridge_target_id = "${var.solution_prefix}-ingestion-sm-target"
      log_group_name         = "/${var.solution_prefix}/${var.solution_prefix}-ingestion-sm"
      log_retention          = 90
    }
  }

  lambda = {
    ingestion_input_validation = {
      name                     = "${var.solution_prefix}-${var.lambda_ingestion_input_validation_prop.image_tag}"
      docker_image_tag         = var.lambda_ingestion_input_validation_prop.image_tag
      source_path              = var.lambda_ingestion_input_validation_prop.src_path
      dir_sha                  = sha1(join("", [for f in fileset(var.lambda_ingestion_input_validation_prop.src_path, "*") : filesha1("${var.lambda_ingestion_input_validation_prop.src_path}/${f}")]))
      platform                 = var.container_platform
      runtime_architecture     = var.container_platform == "linux/arm64" ? "arm64" : "x86_64"
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_ingestion_input_validation_prop.image_tag}-log"
      timeout                  = 900
      memory_size              = 7076
      environment = {
        variables = {
          GRAPHQL_URL = local.graph_ql_url
        }
      }
      vpc_config = {
        subnet_ids         = var.lambda_ingestion_input_validation_prop.subnet_ids
        security_group_ids = var.lambda_ingestion_input_validation_prop.security_group_ids
      }
    }

    file_transformer = {
      name                     = "${var.solution_prefix}-${var.lambda_file_transformer_prop.image_tag}"
      docker_image_tag         = var.lambda_file_transformer_prop.image_tag
      source_path              = var.lambda_file_transformer_prop.src_path
      dir_sha                  = sha1(join("", [for f in fileset(var.lambda_file_transformer_prop.src_path, "*") : filesha1("${var.lambda_file_transformer_prop.src_path}/${f}")]))
      platform                 = var.container_platform
      runtime_architecture     = var.container_platform == "linux/arm64" ? "arm64" : "x86_64"
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_file_transformer_prop.image_tag}-log"
      timeout                  = 900
      memory_size              = 7076
      environment = {
        variables = {
          INPUT_BUCKET  = var.input_assets_bucket_prop.bucket_name
          OUTPUT_BUCKET = var.processed_assets_bucket_prop.bucket_name
          GRAPHQL_URL   = local.graph_ql_url
        }
      }
      vpc_config = {
        subnet_ids         = var.lambda_file_transformer_prop.subnet_ids
        security_group_ids = var.lambda_file_transformer_prop.security_group_ids
      }
    }

    embeddings_job = {
      name                     = "${var.solution_prefix}-${var.lambda_embeddings_job_prop.image_tag}"
      docker_image_tag         = var.lambda_embeddings_job_prop.image_tag
      source_path              = var.lambda_embeddings_job_prop.src_path
      dir_sha                  = sha1(join("", [for f in fileset(var.lambda_embeddings_job_prop.src_path, "*") : filesha1("${var.lambda_embeddings_job_prop.src_path}/${f}")]))
      platform                 = var.container_platform
      runtime_architecture     = var.container_platform == "linux/arm64" ? "arm64" : "x86_64"
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_embeddings_job_prop.image_tag}-log"
      timeout                  = 900
      memory_size              = 7076
      environment = {
        variables = {
          INPUT_BUCKET               = var.input_assets_bucket_prop.bucket_name
          OUTPUT_BUCKET              = var.processed_assets_bucket_prop.bucket_name
          GRAPHQL_URL                = local.graph_ql_url
          OPENSEARCH_API_NAME        = var.opensearch_prop.type
          OPENSEARCH_DOMAIN_ENDPOINT = var.opensearch_prop.endpoint
          OPENSEARCH_INDEX           = var.opensearch_prop.index_name
          OPENSEARCH_SECRET_ID       = var.opensearch_prop.secret
        }
      }
      vpc_config = {
        subnet_ids         = var.lambda_embeddings_job_prop.subnet_ids
        security_group_ids = var.lambda_embeddings_job_prop.security_group_ids
      }
    }
  }

  statemachine = {
    ingestion = {
      name = "${var.solution_prefix}-ingestion-sm"
      logging_configuration = {
        level                  = "ALL"
        include_execution_data = true
      }
    }
  }

  graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.ingestion_api.uris["GRAPHQL"] : var.merged_api_url
}
