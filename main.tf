provider "aws" {
  region = "us-east-1"
  profile = "gen-ai"
}
# tflint-ignore: terraform_unused_declarations
data "aws_caller_identity" "current_account" {}
# tflint-ignore: terraform_unused_declarations
data "aws_region" "current_region" {}

module "networking_resources" {
  source = "./modules/networking-resources"
  stage = var.stage
}

module "persistence_resources" {
  source = "./modules/persistence-resources"
  open_search-service_type = "aoss"
  open_search_props = {
    open_search_vpc_endpoint_id = module.networking_resources.opensearch_vpc_endpoint
    collection_name = "doc-explorer"
  }
  public_subnet_id = module.networking_resources.public_subnet_id
  private_subnet_id = module.networking_resources.private_subnet_id
  isolated_subnet_id = module.networking_resources.isolated_subnet_id
  primary_security_group_id = module.networking_resources.primary_security_group_id
  lambda_security_group_id = module.networking_resources.lambda_security_group_id
  bucket_prefix = var.bucket_prefix
  stage = var.stage
}

# module "my_module" {
#   source         = "./modules/aws-qa-appsync-opensearch"
#   api_log_config = null
#   bucket_inputs_assets_props = null
#   bucket_props = null
#   cognito_user_pool_id = "cognito_user_pool_id"
#   constructor_name = var.constructor_name
#   deploy_vpc = null
#   enable_operational_metric = null
#   enable_xray = null
#   existing_bucket_interface = null
#   existing_bus_interface = null
#   existing_input_assets_bucket_obj = {
#     bucket: "bucket_name"
#     id: "bucket_id"
#   }
#   existing_logging_bucket_obj = null
#   existing_merged_api = null
#   existing_opensearch_domain = {
#     domain_name = "test_name"
#     endpoint = "test_endpoint"
#   }
#   existing_security_group_id = null
#   existing_vpc = null
#   id = var.id
#   log_s3_access_logs = null
#   logging_bucket_props = null
#   open_search_index_name = null
#   open_search_secret = {arn = "some_arn", secret_name = "secret_name"}
#   stage = var.stage
#   vpc_props = {
#     name: "VPC"
#     cidr_block: "10.0.0.0/16"
#   }
#   use_existing_merged_api = false
#   project_version            = var.project_version
# }