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

# variable "bucket_prefix" {}
# variable "stage" {}
# variable "vpc_id" {
#   description = "The ID of the VPC"
#   type        = string
# }
# variable "service_access_log_bucket_arn" {}
# variable "cognito_user_pool_id" {}
# variable "open_search_secret" {}
# variable "input_assets_bucket_arn" {}
# variable "access_logs_bucket_name" {}
# variable "access_logs_bucket_arn" {}
# variable "input_assets_bucket_name" {}
# variable "existing_opensearch_domain_mame" {}
# variable "existing_open_search_domain_endpoint" {}
# variable "opensearch_serverless_collection_endpoint" {}
# variable "existing_open_search_index_name" {}
# variable "app_prefix" {}
# variable "security_groups_ids" { type = list(string) }
# variable "subnet_ids" { type = list(string) }
# variable "ecr_repository_url" {}

# variable "merged_api_url" {
#   type    = string
#   default = ""
# }
