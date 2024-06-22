variable "app_prefix" {}
variable "stage" {}

variable "existing_opensearch_domain_mame" {}
variable "existing_open_search_domain_endpoint" {}
variable "existing_open_search_index_name" {}
variable "opensearch_serverless_collection_endpoint" {}
variable "open_search_secret" {}

variable "input_assets_bucket_name" {}
variable "input_assets_bucket_arn" {}
variable "processed_assets_bucket_name" {}
variable "processed_assets_bucket_arn" {}

variable "security_groups_ids" {type = list(string)}
variable "subnet_ids" {type = list(string)}
variable "cognito_user_pool_id" {}
variable "ecr_repository_url" {}
