variable "solution_prefix" {
  description = "Prefix to be included in all resources deployed by this solution"
  type        = string
  default     = "aws-ia"
}

variable "tags" {
  description = "Map of tags to apply to resources deployed by this solution."
  type        = map(any)
  default     = null
}

variable "cognito_user_pool_id" {
  description = "Cognito user pool for AppSync"
  type        = string
}

variable "ecr_repository_id" {
  description = "ECR Repo Name"
  type        = string
}

variable "lambda_doc_ingestion_prop" {
  description = "Properties for Lambda document ingestion"
  type        = map(any)
}

# variable "app_prefix" {
#   type = string
# }
# variable "stage" {
#   type = string
# }

# variable "existing_opensearch_domain_mame" {}
# variable "existing_open_search_domain_endpoint" {}
# variable "existing_open_search_index_name" {
#   type = string
# }
# variable "opensearch_serverless_collection_endpoint" {}
# variable "open_search_secret" {
#   type = string
# }

# variable "input_assets_bucket_name" {
#   type = string
# }
# variable "input_assets_bucket_arn" { type = string }
# variable "processed_assets_bucket_name" {type = string}
# variable "processed_assets_bucket_arn" {type = string}

# variable "security_groups_ids" {type = list(string)}
# variable "subnet_ids" {type = list(string)}

# variable "ecr_repository_url" {type = string}

# variable "merged_api_url" {
#   type = string
#   default = ""
# }
