resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
}

############################################################################################################
# Networking resources
############################################################################################################

module "networking_resources" {
  source = "./modules/networking-resources"

  solution_prefix = local.solution_prefix
  vpc_props       = var.vpc_props
  tags            = local.root_combined_tags
}

############################################################################################################
# Persistent resources
############################################################################################################

module "persistence_resources" {
  source = "./modules/persistence-resources"

  solution_prefix          = local.solution_prefix
  open_search_service_type = "aoss"
  open_search_props = merge(
    var.open_search_props,
    {
      "subnet_ids" = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    },
    {
      "master_user_arn" = data.aws_caller_identity.current.arn
    },
    {
      "open_search_vpc_endpoint_id" = module.networking_resources.open_search_vpc_endpoint_id
    }
  )
  force_destroy = var.force_destroy
  target_merge_apis = [
    module.document_ingestion.ingestion_api_arn,
    module.summarization.summarization_api_arn,
    module.question_answering.question_answering_arn,
  ]
  tags = local.root_combined_tags
}

############################################################################################################
# Document Ingestion
############################################################################################################

module "document_ingestion" {
  source = "./modules/document-ingestion"

  solution_prefix      = local.solution_prefix
  cognito_user_pool_id = module.persistence_resources.cognito_user_pool_id
  ecr_repository_id    = module.persistence_resources.ecr_repository_id

  lambda_ingestion_input_validation_prop = {
    image_tag          = "ingestion_input_validation"
    src_path           = "${path.module}/lambda/document-ingestion/input_validation/src"
    subnet_ids         = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    security_group_ids = [module.networking_resources.lambda_sg]
  }

  lambda_file_transformer_prop = {
    image_tag          = "file_transformer"
    src_path           = "${path.module}/lambda/document-ingestion/s3_file_transformer/src"
    subnet_ids         = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    security_group_ids = [module.networking_resources.lambda_sg]
  }

  lambda_embeddings_job_prop = {
    image_tag          = "embeddings_job"
    src_path           = "${path.module}/lambda/document-ingestion/embeddings_job/src"
    subnet_ids         = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    security_group_ids = [module.networking_resources.lambda_sg]
  }

  input_assets_bucket_prop = {
    bucket_arn  = module.persistence_resources.input_assets_bucket_arn
    bucket_name = module.persistence_resources.input_assets_bucket_name
  }

  processed_assets_bucket_prop = {
    bucket_arn  = module.persistence_resources.processed_assets_bucket_arn
    bucket_name = module.persistence_resources.processed_assets_bucket_name
  }

  opensearch_prop = local.final_opensearch_prop

  merged_api_arn = module.persistence_resources.merged_api_arn
  merged_api_url = module.persistence_resources.merged_api_url

  container_platform = var.container_platform
  tags               = local.root_combined_tags
}

resource "awscc_appsync_source_api_association" "document_ingestion_association" {
  description           = "Association for document ingestion"
  merged_api_identifier = module.persistence_resources.merged_api_arn
  source_api_identifier = module.document_ingestion.ingestion_api_arn

  source_api_association_config = {
    merge_type = "AUTO_MERGE"
  }
}

############################################################################################################
# Summarization
############################################################################################################

module "summarization" {
  source = "./modules/summarization"

  solution_prefix      = local.solution_prefix
  cognito_user_pool_id = module.persistence_resources.cognito_user_pool_id
  ecr_repository_id    = module.persistence_resources.ecr_repository_id

  lambda_summarization_input_validation_prop = {
    image_tag          = "summarization_input_validation"
    src_path           = "${path.module}/lambda/summarization/input_validator"
    subnet_ids         = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    security_group_ids = [module.networking_resources.lambda_sg]
  }

  lambda_summarization_doc_reader_prop = {
    image_tag          = "summarization_doc_reader"
    src_path           = "${path.module}/lambda/summarization/document_reader"
    subnet_ids         = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    security_group_ids = [module.networking_resources.lambda_sg]
  }

  lambda_summarization_generator_prop = {
    image_tag          = "summarization_generator"
    src_path           = "${path.module}/lambda/summarization/summary_generator"
    subnet_ids         = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    security_group_ids = [module.networking_resources.lambda_sg]
  }

  input_assets_bucket_prop = {
    bucket_arn  = module.persistence_resources.input_assets_bucket_arn
    bucket_name = module.persistence_resources.input_assets_bucket_name
  }

  processed_assets_bucket_prop = {
    bucket_arn  = module.persistence_resources.processed_assets_bucket_arn
    bucket_name = module.persistence_resources.processed_assets_bucket_name
  }

  merged_api_arn = module.persistence_resources.merged_api_arn
  merged_api_url = module.persistence_resources.merged_api_url

  is_file_transformation_required = true

  container_platform = var.container_platform
  tags               = local.root_combined_tags
}

resource "awscc_appsync_source_api_association" "summarization_association" {
  description           = "Association for summarization"
  merged_api_identifier = module.persistence_resources.merged_api_arn
  source_api_identifier = module.summarization.summarization_api_arn

  source_api_association_config = {
    merge_type = "AUTO_MERGE"
  }

  depends_on = [module.persistence_resources, module.summarization]
}

############################################################################################################
# Question Answering
############################################################################################################

module "question_answering" {
  source = "./modules/question-answering"

  solution_prefix      = local.solution_prefix
  cognito_user_pool_id = module.persistence_resources.cognito_user_pool_id
  ecr_repository_id    = module.persistence_resources.ecr_repository_id

  lambda_question_answering_prop = {
    image_tag          = "question_answering"
    src_path           = "${path.module}/lambda/aws-qa-appsync-opensearch/question_answering/src"
    subnet_ids         = [for _, value in module.networking_resources.private_subnet_attributes_by_az : value.id]
    security_group_ids = [module.networking_resources.lambda_sg]
  }

  merged_api_arn = module.persistence_resources.merged_api_arn
  merged_api_url = module.persistence_resources.merged_api_url

  processed_assets_bucket_prop = {
    bucket_arn  = module.persistence_resources.processed_assets_bucket_arn
    bucket_name = module.persistence_resources.processed_assets_bucket_name
  }

  opensearch_prop = local.final_opensearch_prop

  container_platform = var.container_platform
  tags               = local.root_combined_tags

}

resource "awscc_appsync_source_api_association" "question_answering_association" {
  description           = "Association for question answering"
  merged_api_identifier = module.persistence_resources.merged_api_arn
  source_api_identifier = module.question_answering.question_answering_arn

  source_api_association_config = {
    merge_type = "AUTO_MERGE"
  }

  depends_on = [module.persistence_resources, module.question_answering]
}
