############################################################################################################
# Summarization Input Validation Lambda
############################################################################################################

module "docker_image_summarization_input_validation" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.7.0"

  ecr_repo      = var.ecr_repository_id
  use_image_tag = true
  image_tag     = local.lambda.summarization_input_validation.docker_image_tag
  source_path   = local.lambda.summarization_input_validation.source_path
  platform      = local.lambda.summarization_input_validation.platform

  triggers = {
    dir_sha = local.lambda.summarization_input_validation.dir_sha
  }
}

resource "aws_lambda_function" "summarization_input_validation" {
  function_name = local.lambda.summarization_input_validation.name
  description   = local.lambda.summarization_input_validation.description
  role          = aws_iam_role.summarization_input_validation.arn
  image_uri     = module.docker_image_summarization_input_validation.image_uri
  package_type  = "Image"
  architectures = [local.lambda.summarization_input_validation.runtime_architecture]
  timeout       = local.lambda.summarization_input_validation.timeout
  memory_size   = local.lambda.summarization_input_validation.memory_size
  vpc_config {
    subnet_ids         = local.lambda.summarization_input_validation.vpc_config.subnet_ids
    security_group_ids = local.lambda.summarization_input_validation.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.summarization_input_validation.environment.variables
  }
  tags = local.combined_tags
}

############################################################################################################
# Summarization Doc Reader Lambda
############################################################################################################

module "docker_image_summarization_doc_reader" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.7.0"

  ecr_repo      = var.ecr_repository_id
  use_image_tag = true
  image_tag     = local.lambda.summarization_doc_reader.docker_image_tag
  source_path   = local.lambda.summarization_doc_reader.source_path
  platform      = local.lambda.summarization_doc_reader.platform

  triggers = {
    dir_sha = local.lambda.summarization_doc_reader.dir_sha
  }
}

resource "aws_lambda_function" "summarization_doc_reader" {
  function_name = local.lambda.summarization_doc_reader.name
  description   = local.lambda.summarization_doc_reader.description
  role          = aws_iam_role.summarization_doc_reader.arn
  image_uri     = module.docker_image_summarization_doc_reader.image_uri
  package_type  = "Image"
  architectures = [local.lambda.summarization_doc_reader.runtime_architecture]
  timeout       = local.lambda.summarization_doc_reader.timeout
  memory_size   = local.lambda.summarization_doc_reader.memory_size
  vpc_config {
    subnet_ids         = local.lambda.summarization_doc_reader.vpc_config.subnet_ids
    security_group_ids = local.lambda.summarization_doc_reader.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.summarization_doc_reader.environment.variables
  }
  tags = local.combined_tags
}

############################################################################################################
# Summarization Generator Lambda
############################################################################################################

module "docker_image_summarization_generator" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.7.0"

  ecr_repo      = var.ecr_repository_id
  use_image_tag = true
  image_tag     = local.lambda.summarization_generator.docker_image_tag
  source_path   = local.lambda.summarization_generator.source_path
  platform      = local.lambda.summarization_generator.platform

  triggers = {
    dir_sha = local.lambda.summarization_generator.dir_sha
  }
}

resource "aws_lambda_function" "summarization_generator" {
  function_name = local.lambda.summarization_generator.name
  description   = local.lambda.summarization_generator.description
  role          = aws_iam_role.summarization_generator.arn
  image_uri     = module.docker_image_summarization_generator.image_uri
  package_type  = "Image"
  architectures = [local.lambda.summarization_generator.runtime_architecture]
  timeout       = local.lambda.summarization_generator.timeout
  memory_size   = local.lambda.summarization_generator.memory_size
  vpc_config {
    subnet_ids         = local.lambda.summarization_generator.vpc_config.subnet_ids
    security_group_ids = local.lambda.summarization_generator.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.summarization_generator.environment.variables
  }
  tags = local.combined_tags
}