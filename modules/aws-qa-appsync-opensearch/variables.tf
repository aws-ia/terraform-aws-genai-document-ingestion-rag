variable "prefix" {
  default = "appsync_terraform_go_example"
}
variable "stage" {}

variable "observability" {
  type = bool
  default = true
}

variable "deploy_vpc" {
  type = bool
  default = true
}
variable "vpc_props" {}
variable "existing_vpc" {}
variable "bucket_props" {}
variable "existing_logging_bucket_obj" {}
variable "logging_bucket_props" {}
variable "log_s3_access_logs" {}
variable "existing_security_group_id" {}
variable "existing_bucket_interface" {}
variable "existing_input_assets_bucket_obj" {}
variable "bucket_inputs_assets_props" {}
variable "enable_xray" {}
variable "api_log_config" {}
variable "existing_merged_api" {}
variable "existing_bus_interface" {}
variable "open_search_secret" {}
variable "existing_opensearch_domain" {}
variable "open_search_index_name" {}
variable "enable_operational_metric" {}
variable "constructor_name" {}
variable "id" {}
variable "cognito_user_pool_id" {}
variable "use_existing_merged_api" {}
variable "project_version" {}
