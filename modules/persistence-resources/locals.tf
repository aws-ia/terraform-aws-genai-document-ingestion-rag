locals {
  combined_tags = merge(
    var.tags,
    {
      Solution = var.solution_prefix
    }
  )

  opensearch = {
    domain_name = "${var.solution_prefix}-${var.open_search_props.domain_name}"
  }

  opensearch_serverless = {
    collection_name = "${var.solution_prefix}-${var.open_search_props.collection_name}"
  }

  cognito = {
    user_pool_name = "${var.solution_prefix}"
  }

  ecr = {
    repository_name = "${var.solution_prefix}"
  }

  s3 = {
    access_logs = {
      bucket = substr("${var.solution_prefix}-access-logs", 0, 62) # limit bucket name to 63 chars
      versioning_configuration_status = "Enabled"
      sse_algorithm = "AES256" # access log use only AES256

    }
    
    assets_name = {
      bucket = substr("${var.solution_prefix}-assets", 0, 62)
      versioning_configuration_status = "Enabled"
    }
  }
}