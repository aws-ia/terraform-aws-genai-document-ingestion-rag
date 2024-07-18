locals {
  combined_tags = merge(
    var.tags,
    {
      Submodule = "summarization"
    }
  )

  graphql = {
    summarization_api = {
      name                         = "${var.solution_prefix}-summarization-api"
      cloudwatch_log_role_name     = "${var.solution_prefix}-summarization-api-log"
      event_bridge_datasource_name = replace("${var.solution_prefix}-summarization-datasource", "-", "_") # must match pattern [_A-Za-z][_0-9A-Za-z]*
      status_datasource_name       = replace("${var.solution_prefix}-summarization-status-datasource", "-", "_")
    }
  }

  cloudwatch = {
    summarization = {
      event_bus_name = "${var.solution_prefix}-summarization-event-bus"
      log_group_name = "/${var.solution_prefix}/${var.solution_prefix}-summarization-log-group"
      log_retention  = 90
    }
    summarization_sm = {
      event_bridge_target_id = "${var.solution_prefix}-summarization-sm-target"
      log_group_name         = "/${var.solution_prefix}/${var.solution_prefix}-summarization-sm"
      log_retention          = 90
    }
  }

  statemachine = {
    summarization = {
      name = "${var.solution_prefix}-summarization-sm"
      logging_configuration = {
        level                  = "ALL"
        include_execution_data = true
      }
    }
  }

  lambda = {
    summarization_input_validation = {
      name                     = "${var.solution_prefix}-${var.lambda_summarization_input_validation_prop.image_tag}"
      docker_image_tag         = var.lambda_summarization_input_validation_prop.image_tag
      source_path              = var.lambda_summarization_input_validation_prop.src_path
      dir_sha                  = sha1(join("", [for f in fileset(var.lambda_summarization_input_validation_prop.src_path, "*") : filesha1("${var.lambda_summarization_input_validation_prop.src_path}/${f}")]))
      platform                 = var.container_platform
      runtime_architecture     = var.container_platform == "linux/arm64" ? "arm64" : "x86_64"
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_summarization_input_validation_prop.image_tag}-log"
      timeout                  = 600
      memory_size              = 1769
      environment = {
        variables = {
          GRAPHQL_URL = local.graph_ql_url
        }
      }
      vpc_config = {
        subnet_ids         = var.lambda_summarization_input_validation_prop.subnet_ids
        security_group_ids = var.lambda_summarization_input_validation_prop.security_group_ids
      }
    }

    summarization_doc_reader = {
      name                     = "${var.solution_prefix}-${var.lambda_summarization_doc_reader_prop.image_tag}"
      docker_image_tag         = var.lambda_summarization_doc_reader_prop.image_tag
      source_path              = var.lambda_summarization_doc_reader_prop.src_path
      dir_sha                  = sha1(join("", [for f in fileset(var.lambda_summarization_doc_reader_prop.src_path, "*") : filesha1("${var.lambda_summarization_doc_reader_prop.src_path}/${f}")]))
      platform                 = var.container_platform
      runtime_architecture     = var.container_platform == "linux/arm64" ? "arm64" : "x86_64"
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_summarization_doc_reader_prop.image_tag}-log"
      timeout                  = 600
      memory_size              = 1769
      environment = {
        variables = {
          TRANSFORMED_ASSET_BUCKET = var.processed_assets_bucket_prop.bucket_name
          INPUT_ASSET_BUCKET       = var.input_assets_bucket_prop.bucket_name
          IS_FILE_TRANSFORMED      = var.is_file_transformation_required
          GRAPHQL_URL              = local.graph_ql_url
        }
      }
      vpc_config = {
        subnet_ids         = var.lambda_summarization_doc_reader_prop.subnet_ids
        security_group_ids = var.lambda_summarization_doc_reader_prop.security_group_ids
      }
    }

    summarization_generator = {
      name                     = "${var.solution_prefix}-${var.lambda_summarization_generator_prop.image_tag}"
      docker_image_tag         = var.lambda_summarization_generator_prop.image_tag
      source_path              = var.lambda_summarization_generator_prop.src_path
      dir_sha                  = sha1(join("", [for f in fileset(var.lambda_summarization_generator_prop.src_path, "*") : filesha1("${var.lambda_summarization_generator_prop.src_path}/${f}")]))
      platform                 = var.container_platform
      runtime_architecture     = var.container_platform == "linux/arm64" ? "arm64" : "x86_64"
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_summarization_generator_prop.image_tag}-log"
      timeout                  = 600
      memory_size              = 1769
      environment = {
        variables = {
          GRAPHQL_URL            = local.graph_ql_url
          ASSET_BUCKET_NAME      = var.processed_assets_bucket_prop.bucket_name
          SUMMARY_LLM_CHAIN_TYPE = var.summary_chain_type
        }
      }
      vpc_config = {
        subnet_ids         = var.lambda_summarization_generator_prop.subnet_ids
        security_group_ids = var.lambda_summarization_generator_prop.security_group_ids
      }
    }
  }
  # update_graphql_api_id                     = var.existing_merged_api_id != "" ? var.existing_merged_api_id : aws_appsync_graphql_api.summarization_graphql_api.id

  graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.summarization_api.uris["GRAPHQL"] : var.merged_api_url
}
