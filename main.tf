resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
}

module "networking_resources" {
  source = "./modules/networking-resources"

  solution_prefix = local.solution_prefix
  vpc_props       = var.vpc_props
}

# module "persistence_resources" {
#   source = "./modules/persistence-resources"

#   open_search_service_type = "aoss"
#   open_search_props = {
#     open_search_vpc_endpoint_id = module.networking_resources.opensearch_vpc_endpoint
#     collection_name = "doc-explorer"
#   }

#   subnets = [ for _, value in module.networking_resources.private_subnet_attributes_by_az: value.id]

#   primary_security_group_id = module.networking_resources.primary_security_group_id
#   lambda_security_group_id = module.networking_resources.lambda_security_group_id
#   bucket_prefix = var.bucket_prefix
#   stage = var.stage
#   app_prefix = random_string.app_prefix.result
#   merged_api_name = var.merged_api_name

# }

# data "local_file" "merged_api_id" {
#   filename = "merged_api_id.txt"
#   depends_on = [module.persistence_resources]
# }

# data "local_file" "merged_api_url" {
#   filename = "merged_api_url.txt"
#   depends_on = [module.persistence_resources]
# }

# resource "null_resource" "ecr_login" {
#   provisioner "local-exec" {
#     command = <<EOT
#       docker logout ${module.persistence_resources.ecr_repository_url} || true
#       echo "Attempting to remove existing credentials from keychain..."

#       # Explicitly remove the Docker credentials if they exist
#       EXISTING_CREDS=$(security find-generic-password -s "docker-credential-osxkeychain" -a "${module.persistence_resources.ecr_repository_url}" 2>&1)
#       if [[ $EXISTING_CREDS == *"attributes"* ]]; then
#         security delete-generic-password -s "docker-credential-osxkeychain" -a "${module.persistence_resources.ecr_repository_url}"
#       fi

#       # Authenticate Docker with ECR
#       aws ecr get-login-password --region ${data.aws_region.current_region.name} | docker login --username AWS --password-stdin ${module.persistence_resources.ecr_repository_url}
#     EOT
#   }

#   triggers = {
#     always_run = timestamp()
#   }
# }

# module "question-answering" {
#   source = "./modules/question-answering"
#   bucket_prefix = "gen-ai"
#   stage = "_dev"
#   subnet_ids = [tostring(module.networking_resources.public_subnet_id), tostring(module.networking_resources.private_subnet_id), tostring(module.networking_resources.isolated_subnet_id)]
#   security_groups_ids = [tostring(module.networking_resources.primary_security_group_id), tostring(module.networking_resources.lambda_security_group_id)]
#   cognito_user_pool_id = module.persistence_resources.cognito_user_pool_id
#   input_assets_bucket_arn = module.persistence_resources.input_assets_bucket_arn
#   input_assets_bucket_name = module.persistence_resources.input_assets_bucket_name
#   existing_opensearch_domain_mame = module.persistence_resources.existing_opensearch_domain_mame
#   existing_open_search_domain_endpoint = module.persistence_resources.existing_open_search_domain_endpoint
#   existing_open_search_index_name = "doc-rag-search"
#   open_search_secret = "NONE"
#   vpc_id = module.networking_resources.vpc_id
#   service_access_log_bucket_arn = module.persistence_resources.access_logs_bucket_arn
#   opensearch_serverless_collection_endpoint = module.persistence_resources.opensearch_serverless_collection_endpoint
#   app_prefix = random_string.app_prefix.result
#   access_logs_bucket_arn = module.persistence_resources.access_logs_bucket_arn
#   access_logs_bucket_name = module.persistence_resources.access_logs_bucket_name
#   ecr_repository_url = module.persistence_resources.ecr_repository_url
#   merged_api_url = local.merged_api_url

#   depends_on = [module.networking_resources, module.persistence_resources, null_resource.ecr_login]
# }

# module "document-ingestion" {
#   source = "./modules/document-ingestion"
#   app_prefix = random_string.app_prefix.result
#   existing_opensearch_domain_mame = module.persistence_resources.existing_opensearch_domain_mame
#   existing_open_search_domain_endpoint = module.persistence_resources.existing_open_search_domain_endpoint
#   existing_open_search_index_name = "doc-rag-search"
#   subnet_ids = [tostring(module.networking_resources.public_subnet_id), tostring(module.networking_resources.private_subnet_id), tostring(module.networking_resources.isolated_subnet_id)]
#   security_groups_ids = [tostring(module.networking_resources.primary_security_group_id), tostring(module.networking_resources.lambda_security_group_id)]
#   input_assets_bucket_arn = module.persistence_resources.input_assets_bucket_arn
#   input_assets_bucket_name = module.persistence_resources.input_assets_bucket_name
#   opensearch_serverless_collection_endpoint = module.persistence_resources.opensearch_serverless_collection_endpoint
#   open_search_secret = "NONE"
#   processed_assets_bucket_arn = module.persistence_resources.processed_assets_bucket_arn
#   processed_assets_bucket_name = module.persistence_resources.processed_assets_bucket_name
#   cognito_user_pool_id = module.persistence_resources.cognito_user_pool_id
#   stage = "dev"
#   ecr_repository_url = module.persistence_resources.ecr_repository_url
#   merged_api_url = local.merged_api_url

#   depends_on = [module.networking_resources, module.persistence_resources, null_resource.ecr_login]
# }

# module "summarization" {
#   source = "./modules/summarization"
#   app_prefix = random_string.app_prefix.result
#   ecr_repository_url = module.persistence_resources.ecr_repository_url
#   input_assets_bucket_arn = module.persistence_resources.input_assets_bucket_arn
#   input_assets_bucket_name = module.persistence_resources.input_assets_bucket_name
#   processed_assets_bucket_arn = module.persistence_resources.processed_assets_bucket_arn
#   processed_assets_bucket_name = module.persistence_resources.processed_assets_bucket_name
#   security_groups_ids = [tostring(module.networking_resources.primary_security_group_id), tostring(module.networking_resources.lambda_security_group_id)]
#   subnet_ids = [tostring(module.networking_resources.public_subnet_id), tostring(module.networking_resources.private_subnet_id), tostring(module.networking_resources.isolated_subnet_id)]
#   vpc_id = module.networking_resources.vpc_id
#   access_logs_bucket_arn  = module.persistence_resources.access_logs_bucket_arn
#   access_logs_bucket_name = module.persistence_resources.access_logs_bucket_name
#   cognito_user_pool_id    = module.persistence_resources.cognito_user_pool_id
#   stage                   = var.stage
#   merged_api_url = local.merged_api_url

#   depends_on = [module.networking_resources, module.persistence_resources, null_resource.ecr_login]
# }

# # APIs association
# resource "awscc_appsync_source_api_association" "question-answering_association" {
#   description             = "Association for question-answering"
#   merged_api_identifier   = local.merged_api_id
#   source_api_identifier   = module.question-answering.question_answering_graphql_api_id

#   source_api_association_config = {
#     merge_type = "AUTO_MERGE"
#   }
#   depends_on = [module.persistence_resources, module.question-answering]
# }
# resource "awscc_appsync_source_api_association" "document_ingestion_association" {
#   description             = "Association for document ingestion"
#   merged_api_identifier   = local.merged_api_id
#   source_api_identifier   = module.document-ingestion.ingestion_graphql_api_id

#   source_api_association_config = {
#     merge_type = "AUTO_MERGE"
#   }

#   depends_on = [module.persistence_resources, module.document-ingestion]
# }
# resource "awscc_appsync_source_api_association" "summarization_association" {
#   description             = "Association for summarization"
#   merged_api_identifier   = local.merged_api_id
#   source_api_identifier   = module.summarization.summarization_graphql_api_id

#   source_api_association_config = {
#     merge_type = "AUTO_MERGE"
#   }

#   depends_on = [module.persistence_resources, module.summarization]
# }
