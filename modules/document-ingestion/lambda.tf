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

# # Lambda Function for Embeddings Job
# resource "null_resource" "build_and_push_embeddings_job_lambda_image" {
#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "local-exec" {
#     environment = {
#       REPOSITORY_URL = var.ecr_repository_url
#       AWS_REGION     = data.aws_region.current_region.name
#       IMAGE_NAME = local.embeddings_job_lambda_image_name
#     }
#     command = "${abspath(path.module)}/../../lambda/document-ingestion/embeddings_job/src/build_push_docker.sh"
#   }
# }

# resource "aws_lambda_function" "embeddings_job_lambda" {
#   function_name    = "${var.app_prefix}_embeddings_job_docker"
#   role             = aws_iam_role.lambda_exec_role.arn
#   image_uri     = "${var.ecr_repository_url}:${local.embeddings_job_lambda_image_name}"
#   package_type  = "Image"
#   timeout = 600
#   environment {
#     variables = {
#       OUTPUT_BUCKET           = var.processed_assets_bucket_name
#       GRAPHQL_URL             = local.graph_ql_url
#       INPUT_BUCKET               = var.input_assets_bucket_name
#       OPENSEARCH_DOMAIN_ENDPOINT = local.selected_open_search_endpoint
#       OPENSEARCH_INDEX           = var.existing_open_search_index_name
#       OPENSEARCH_SECRET_ID       = var.open_search_secret
#     }
#   }
# #   vpc_config {
# #     subnet_ids = var.subnet_ids
# #     security_group_ids = var.security_groups_ids
# #   }
#   depends_on = [null_resource.build_and_push_embeddings_job_lambda_image]
# }
