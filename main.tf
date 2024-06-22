provider "aws" {
  region = "us-east-1"
  profile = "default"
}
# tflint-ignore: terraform_unused_declarations
data "aws_caller_identity" "current_account" {}
# tflint-ignore: terraform_unused_declarations
data "aws_region" "current_region" {}

resource "random_string" "app_prefix" {
  length = 6
  special = false
  upper = false
}

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
  app_prefix = random_string.app_prefix.result

  depends_on = [module.networking_resources]
}

resource "null_resource" "ecr_login" {
  provisioner "local-exec" {
    command = <<EOT
      docker logout ${module.persistence_resources.ecr_repository_url} || true
      echo "Attempting to remove existing credentials from keychain..."

      # Explicitly remove the Docker credentials if they exist
      EXISTING_CREDS=$(security find-generic-password -s "docker-credential-osxkeychain" -a "${module.persistence_resources.ecr_repository_url}" 2>&1)
      if [[ $EXISTING_CREDS == *"attributes"* ]]; then
        security delete-generic-password -s "docker-credential-osxkeychain" -a "${module.persistence_resources.ecr_repository_url}"
      fi

      # Authenticate Docker with ECR
      aws ecr get-login-password --region ${data.aws_region.current_region.name} | docker login --username AWS --password-stdin ${module.persistence_resources.ecr_repository_url}
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

module "question-answering" {
  source = "./modules/question-answering"
  bucket_prefix = "gen-ai"
  stage = "_dev"
  subnet_ids = [tostring(module.networking_resources.public_subnet_id), tostring(module.networking_resources.private_subnet_id), tostring(module.networking_resources.isolated_subnet_id)]
  security_groups_ids = [tostring(module.networking_resources.primary_security_group_id), tostring(module.networking_resources.lambda_security_group_id)]
  cognito_user_pool_id = module.persistence_resources.cognito_user_pool_id
  input_assets_bucket_arn = module.persistence_resources.input_assets_bucket_arn
  input_assets_bucket_name = module.persistence_resources.input_assets_bucket_name
  existing_opensearch_domain_mame = module.persistence_resources.existing_opensearch_domain_mame
  existing_open_search_domain_endpoint = module.persistence_resources.existing_open_search_domain_endpoint
  existing_open_search_index_name = "doc-rag-search"
  open_search_secret = "NONE"
  vpc_id = module.networking_resources.vpc_id
  service_access_log_bucket_arn = module.persistence_resources.access_logs_bucket_arn
  opensearch_serverless_collection_endpoint = module.persistence_resources.opensearch_serverless_collection_endpoint
  app_prefix = random_string.app_prefix.result
  access_logs_bucket_arn = module.persistence_resources.access_logs_bucket_arn
  access_logs_bucket_name = module.persistence_resources.access_logs_bucket_name
  ecr_repository_url = module.persistence_resources.ecr_repository_url

  depends_on = [module.networking_resources, module.persistence_resources, null_resource.ecr_login]
}

module "document-ingestion" {
  source = "./modules/document-ingestion"
  app_prefix = random_string.app_prefix.result
  existing_opensearch_domain_mame = module.persistence_resources.existing_opensearch_domain_mame
  existing_open_search_domain_endpoint = module.persistence_resources.existing_open_search_domain_endpoint
  existing_open_search_index_name = "doc-rag-search"
  subnet_ids = [tostring(module.networking_resources.public_subnet_id), tostring(module.networking_resources.private_subnet_id), tostring(module.networking_resources.isolated_subnet_id)]
  security_groups_ids = [tostring(module.networking_resources.primary_security_group_id), tostring(module.networking_resources.lambda_security_group_id)]
  input_assets_bucket_arn = module.persistence_resources.input_assets_bucket_arn
  input_assets_bucket_name = module.persistence_resources.input_assets_bucket_name
  opensearch_serverless_collection_endpoint = module.persistence_resources.opensearch_serverless_collection_endpoint
  open_search_secret = "NONE"
  processed_assets_bucket_arn = module.persistence_resources.processed_assets_bucket_arn
  processed_assets_bucket_name = module.persistence_resources.processed_assets_bucket_name
  cognito_user_pool_id = module.persistence_resources.cognito_user_pool_id
  stage = "dev"
  ecr_repository_url = module.persistence_resources.ecr_repository_url

  depends_on = [module.networking_resources, module.persistence_resources, null_resource.ecr_login]
}
