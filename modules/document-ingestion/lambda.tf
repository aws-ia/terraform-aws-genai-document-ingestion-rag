# TODO: add Lambda to VPC 

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

}

resource "aws_lambda_function" "ingestion_input_validation" {
  function_name = local.lambda.ingestion_input_validation.name
  role          = aws_iam_role.ingestion_input_validation.arn
  image_uri     = module.docker_image_ingestion_input_validation.image_uri
  package_type  = "Image"
  timeout       = local.lambda.ingestion_input_validation.timeout
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
  image_tag     = local.lambda.ingestion_input_validation.docker_image_tag
  source_path   = local.lambda.ingestion_input_validation.source_path

}

resource "aws_lambda_function" "file_transformer" {
  function_name = local.lambda.file_transformer.name
  role          = aws_iam_role.file_transformer.arn
  image_uri     = module.docker_image_file_transformer.image_uri
  package_type  = "Image"
  timeout       = local.lambda.file_transformer.timeout
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

}

resource "aws_lambda_function" "embeddings_job" {
  function_name = local.lambda.embeddings_job.name
  role          = aws_iam_role.embeddings_job.arn
  image_uri     = module.docker_image_embeddings_job.image_uri
  package_type  = "Image"
  timeout       = local.lambda.embeddings_job.timeout
  environment {
    variables = local.lambda.embeddings_job.environment.variables
  }

  tags = local.combined_tags
}
