variable "app_prefix" {
  type = string
}
variable "stage" {
  type = string
}

variable "existing_opensearch_domain_mame" {}
variable "existing_open_search_domain_endpoint" {}
variable "existing_open_search_index_name" {
  type = string
}
variable "opensearch_serverless_collection_endpoint" {}
variable "open_search_secret" {
  type = string
}

variable "input_assets_bucket_name" {
  type = string
}
variable "input_assets_bucket_arn" { type = string }
variable "processed_assets_bucket_name" {type = string}
variable "processed_assets_bucket_arn" {type = string}

variable "private_subnet_id" {type = string}
variable "security_group_id" {type = string}
variable "cognito_user_pool_id" {type = string}
variable "ecr_repository_url" {type = string}

variable "merged_api_url" {
  type = string
  default = ""
}
