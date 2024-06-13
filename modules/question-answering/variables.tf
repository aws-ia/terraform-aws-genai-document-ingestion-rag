variable "bucket_prefix" {}
variable "stage" {}
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "service_access_log_bucket_arn" {}
variable "cognito_user_pool_id" {}
variable "open_search_secret" {}
variable "input_assets_bucket_arn" {}
variable "input_assets_bucket_name" {}
variable "existing_opensearch_domain_mame" {}
variable "existing_open_search_domain_endpoint" {}
variable "opensearch_serverless_collection_endpoint" {}
variable "existing_open_search_index_name" {}
variable "security_group_id" {}
variable "private_subnet_id" {}
variable "app_prefix" {}
