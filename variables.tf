# General variables
variable "stage" {
  description = "The stage for the deployment, default is '-dev'"
  default = "-dev"
  type = string
}

# tflint-ignore: terraform_unused_declarations
variable "observability" {
  description = "Enable or disable observability, default is true"
  type = bool
  default = true
}

# VPC variables
# tflint-ignore: terraform_unused_declarations
# variable "deploy_vpc" {
#   description = "Specify if a VPC should be deployed, default is null"
#   default = null
#   type = bool
# }

# tflint-ignore: terraform_unused_declarations
# variable "vpc_props" {
#   description = "Properties for the VPC to be deployed. Error if both this and 'deploy_vpc' are provided"
#   type = object({
#     name: string
#     cidr_block: string
#   })
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_vpc" {
#   description = "Existing VPC to be used. If not provided, a new one will be created"
#   type = object({
#     id: string
#   })
#   default = null
# }

# Bucket variables
# tflint-ignore: terraform_unused_declarations
# variable "bucket_props" {
#   description = "Properties for the bucket, default is null"
#   default = null
# }
# # tflint-ignore: terraform_unused_declarations
# variable "existing_logging_bucket_obj" {
#   description = "Existing logging bucket to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "logging_bucket_props" {
#   description = "Properties for the logging bucket, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "log_s3_access_logs" {
#   description = "Enable or disable logging of S3 access logs, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_security_group_id" {
#   description = "Existing security group to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_bucket_interface" {
#   description = "Existing bucket interface to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_input_assets_bucket_obj" {
#   description = "Existing input assets bucket to be used. Provide 'bucket' and 'id' based on your configuration needs"
#   type = object({
#     bucket: string
#     id: string
#   })
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "bucket_inputs_assets_props" {
#   description = "Properties for the input assets bucket, default is null"
#   default = null
# }

# API variables
# tflint-ignore: terraform_unused_declarations
# variable "enable_xray" {
#   description = "Enable or disable X-Ray, default is true"
#   default = true
#   type = bool
# }

# tflint-ignore: terraform_unused_declarations
# variable "api_log_config" {
#   description = "Configuration for API logging, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "use_existing_merged_api" {
#   description = "Use existing merged API, default is false"
#   default = false
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_merged_api" {
#   description = "Existing merged API to be used. Provide 'id' and 'url' based on your configuration needs"
#   type = object({
#     id: string
#     url: string
#   })
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_bus_interface" {
#   description = "Existing bus interface to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "open_search_secret" {
#   description = "Secret for OpenSearch. Provide 'arn' and 'secret_name' based on your configuration needs"
#   type = object({
#     arn: string
#     secret_name: string
#   })
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "enable_operational_metric" {
#   description = "Enable or disable operational metric, default is null"
#   default = null
# }

# Required variables
# tflint-ignore: terraform_unused_declarations
# variable "existing_opensearch_domain" {
#   description = "Existing OpenSearch domain to be used. Provide 'domain_name' and 'endpoint' based on your configuration needs"
#   type = object({
#     domain_name: string
#     endpoint: string
#   })
#   default = {
#     domain_name = "test_name"
#     endpoint = "test_endpoint"
#   }
# }

# tflint-ignore: terraform_unused_declarations
# variable "open_search_index_name" {
#   description = "Name for the OpenSearch index, default is 'test_open_search_index_name'"
#   type = string
#   default = "test_open_search_index_name"
# }

# tflint-ignore: terraform_unused_declarations
# variable "cognito_user_pool_id" {
#   description = "ID for the Cognito user pool, default is 'test_cognito_user_pool_id'"
#   type = string
#   default = "test_cognito_user_pool_id"
# }

# Project variables
# variable "project_version" {
#   description = "Version of the project"
#   type = string
# }

# tflint-ignore: terraform_unused_declarations
# variable "constructor_name" {
#   description = "Name of the constructor"
#   type = string
# }

# variable "id" {
#   description = "ID for the resource"
#   type = string
# }

variable "bucket_prefix" {
  description = "Prefix for usage with s3 bucketnames"
  type = string
  default = "gen-ai"
}