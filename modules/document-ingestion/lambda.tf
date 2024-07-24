############################################################################################################
# Ingestion Input Validation Lambda
############################################################################################################

module "docker_image_ingestion_input_validation" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.7.0"

  ecr_repo      = var.ecr_repository_id
  use_image_tag = true
  image_tag     = local.lambda.ingestion_input_validation.docker_image_tag
  source_path   = local.lambda.ingestion_input_validation.source_path
  platform      = local.lambda.ingestion_input_validation.platform

  triggers = {
    dir_sha = local.lambda.ingestion_input_validation.dir_sha
  }
  #checkov:skip=CKV_TF_1:skip module source commit hash
}

resource "aws_lambda_function" "ingestion_input_validation" {
  function_name = local.lambda.ingestion_input_validation.name
  description   = local.lambda.ingestion_input_validation.description
  role          = aws_iam_role.ingestion_input_validation.arn
  image_uri     = module.docker_image_ingestion_input_validation.image_uri
  package_type  = "Image"
  architectures = [local.lambda.ingestion_input_validation.runtime_architecture]
  timeout       = local.lambda.ingestion_input_validation.timeout
  memory_size   = local.lambda.ingestion_input_validation.memory_size
  kms_key_arn   = aws_kms_key.ingestion.arn
  vpc_config {
    subnet_ids         = local.lambda.ingestion_input_validation.vpc_config.subnet_ids
    security_group_ids = local.lambda.ingestion_input_validation.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.ingestion_input_validation.environment.variables
  }
  tracing_config {
    mode = "Active"
  }
  reserved_concurrent_executions = local.lambda.ingestion_input_validation.lambda_reserved_concurrency
  tags                           = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ, re-drive via state machine
  #checkov:skip=CKV_AWS_272:skip code-signing
}

############################################################################################################
# File Transformer Lambda
############################################################################################################

module "docker_image_file_transformer" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.7.0"

  ecr_repo      = var.ecr_repository_id
  use_image_tag = true
  image_tag     = local.lambda.file_transformer.docker_image_tag
  source_path   = local.lambda.file_transformer.source_path
  platform      = local.lambda.file_transformer.platform

  triggers = {
    dir_sha = local.lambda.file_transformer.dir_sha
  }
  #checkov:skip=CKV_TF_1:skip module source commit hash
}

resource "aws_lambda_function" "file_transformer" {
  function_name = local.lambda.file_transformer.name
  description   = local.lambda.file_transformer.description
  role          = aws_iam_role.file_transformer.arn
  image_uri     = module.docker_image_file_transformer.image_uri
  package_type  = "Image"
  architectures = [local.lambda.file_transformer.runtime_architecture]
  timeout       = local.lambda.file_transformer.timeout
  memory_size   = local.lambda.file_transformer.memory_size
  kms_key_arn   = aws_kms_key.ingestion.arn
  vpc_config {
    subnet_ids         = local.lambda.file_transformer.vpc_config.subnet_ids
    security_group_ids = local.lambda.file_transformer.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.file_transformer.environment.variables
  }
  tracing_config {
    mode = "Active"
  }
  reserved_concurrent_executions = local.lambda.file_transformer.lambda_reserved_concurrency
  tags                           = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ, re-drive via state machine
  #checkov:skip=CKV_AWS_272:skip code-signing
}

############################################################################################################
# Embeddings Job Lambda
############################################################################################################

module "docker_image_embeddings_job" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.7.0"

  ecr_repo      = var.ecr_repository_id
  use_image_tag = true
  image_tag     = local.lambda.embeddings_job.docker_image_tag
  source_path   = local.lambda.embeddings_job.source_path
  platform      = local.lambda.embeddings_job.platform

  triggers = {
    dir_sha = local.lambda.embeddings_job.dir_sha
  }
  #checkov:skip=CKV_TF_1:skip module source commit hash
}

resource "aws_lambda_function" "embeddings_job" {
  function_name = local.lambda.embeddings_job.name
  description   = local.lambda.embeddings_job.description
  role          = aws_iam_role.embeddings_job.arn
  image_uri     = module.docker_image_embeddings_job.image_uri
  package_type  = "Image"
  architectures = [local.lambda.embeddings_job.runtime_architecture]
  timeout       = local.lambda.embeddings_job.timeout
  memory_size   = local.lambda.embeddings_job.memory_size
  kms_key_arn   = aws_kms_key.ingestion.arn
  vpc_config {
    subnet_ids         = local.lambda.embeddings_job.vpc_config.subnet_ids
    security_group_ids = local.lambda.embeddings_job.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.embeddings_job.environment.variables
  }
  tracing_config {
    mode = "Active"
  }
  reserved_concurrent_executions = local.lambda.embeddings_job.lambda_reserved_concurrency
  tags                           = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ, re-drive via state machine
  #checkov:skip=CKV_AWS_272:skip code-signing
}
