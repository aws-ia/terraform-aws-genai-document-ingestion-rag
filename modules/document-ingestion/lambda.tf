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
}

resource "aws_lambda_function" "ingestion_input_validation" {
  function_name = local.lambda.ingestion_input_validation.name
  role          = aws_iam_role.ingestion_input_validation.arn
  image_uri     = module.docker_image_ingestion_input_validation.image_uri
  package_type  = "Image"
  timeout       = local.lambda.ingestion_input_validation.timeout
  memory_size   = local.lambda.ingestion_input_validation.memory_size
  vpc_config {
    subnet_ids         = local.lambda.ingestion_input_validation.vpc_config.subnet_ids
    security_group_ids = local.lambda.ingestion_input_validation.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.ingestion_input_validation.environment.variables
  }
  tags = local.combined_tags
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
}

resource "aws_lambda_function" "file_transformer" {
  function_name = local.lambda.file_transformer.name
  role          = aws_iam_role.file_transformer.arn
  image_uri     = module.docker_image_file_transformer.image_uri
  package_type  = "Image"
  timeout       = local.lambda.file_transformer.timeout
  memory_size   = local.lambda.file_transformer.memory_size
  vpc_config {
    subnet_ids         = local.lambda.file_transformer.vpc_config.subnet_ids
    security_group_ids = local.lambda.file_transformer.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.file_transformer.environment.variables
  }

  tags = local.combined_tags
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
}

resource "aws_lambda_function" "embeddings_job" {
  function_name = local.lambda.embeddings_job.name
  role          = aws_iam_role.embeddings_job.arn
  image_uri     = module.docker_image_embeddings_job.image_uri
  package_type  = "Image"
  timeout       = local.lambda.embeddings_job.timeout
  memory_size   = local.lambda.embeddings_job.memory_size
  vpc_config {
    subnet_ids         = local.lambda.embeddings_job.vpc_config.subnet_ids
    security_group_ids = local.lambda.embeddings_job.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.embeddings_job.environment.variables
  }

  tags = local.combined_tags
}
