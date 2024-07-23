locals {
  combined_tags = merge(
    var.tags,
    {
      Submodule = "question-answering"
    }
  )
  cloudwatch = {
    question_answering = {
      event_bus_name = "${var.solution_prefix}-qa-event-bus"
      log_group_name = "/${var.solution_prefix}/${var.solution_prefix}-qa"
      log_retention  = 90
    }
    question_answering_sm = {
      event_bridge_target_id = "${var.solution_prefix}-qa-sm-target"
      log_group_name         = "/${var.solution_prefix}/${var.solution_prefix}-qa-sm"
      log_retention          = 90
    }
  }

  graphql = {
    question_answering_api = {
      name                         = "${var.solution_prefix}-qa-api"
      cloudwatch_log_role_name     = "${var.solution_prefix}-qa-api-log"
      field_log_level              = "ALL"
      job_status_datasource_name   = replace("${var.solution_prefix}-qa-jobstatus-datasource", "-", "_")   # must match pattern [_A-Za-z][_0-9A-Za-z]*
      event_bridge_datasource_name = replace("${var.solution_prefix}-qa-eventbridge-datasource", "-", "_") # must match pattern [_A-Za-z][_0-9A-Za-z]*
    }
  }

  lambda = {
    question_answering = {
      name                     = "${var.solution_prefix}-${var.lambda_question_answering_prop.image_tag}"
      docker_image_tag         = var.lambda_question_answering_prop.image_tag
      source_path              = var.lambda_question_answering_prop.src_path
      dir_sha                  = sha1(join("", [for f in fileset(var.lambda_question_answering_prop.src_path, "*") : filesha1("${var.lambda_question_answering_prop.src_path}/${f}")]))
      platform                 = var.container_platform
      runtime_architecture     = var.container_platform == "linux/arm64" ? "arm64" : "x86_64"
      cloudwatch_log_role_name = "${var.solution_prefix}-${var.lambda_question_answering_prop.image_tag}-log"
      timeout                  = 900
      memory_size              = 7076
      environment = {
        variables = {
          GRAPHQL_URL = local.graph_ql_url
          INPUT_BUCKET               = var.processed_assets_bucket_prop.bucket_name
          OPENSEARCH_API_NAME        = var.opensearch_prop.type
          OPENSEARCH_DOMAIN_ENDPOINT = var.opensearch_prop.endpoint
          OPENSEARCH_INDEX           = var.opensearch_prop.index_name
          OPENSEARCH_SECRET_ID       = var.opensearch_prop.secret
        }
      }
      vpc_config = {
        subnet_ids         = var.lambda_question_answering_prop.subnet_ids
        security_group_ids = var.lambda_question_answering_prop.security_group_ids
      }
    }
  }

  opensearch_policy = {
    es = {
      actions = [
        "es:ESHttpGet", 
        "es:ESHttpPut", 
        "es:ESHttpPost", 
        "es:ESHttpDelete", 
        "es:ESHttpHead",
      ],
    },
    aoss = {
      actions = [
        "aoss:APIAccess",
      ],
    }
  }
  
  graph_ql_url = var.merged_api_url == "" ? aws_appsync_graphql_api.question_answering_api.uris["GRAPHQL"] : var.merged_api_url
}
