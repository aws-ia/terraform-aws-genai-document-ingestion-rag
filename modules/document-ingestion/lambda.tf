# Build and push Docker image to ECR
resource "null_resource" "build_and_push_input_validation_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = var.ecr_repository_url
      AWS_REGION     = data.aws_region.current_region.name
      IMAGE_NAME = local.ingestion_input_validation_lambda_image_name
    }
    command = "${abspath(path.module)}/../../lambda/document-ingestion/input_validation/src/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "input_validation_lambda" {
  function_name = "${var.app_prefix}-ingestion-input-validation"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = "${var.ecr_repository_url}:${local.ingestion_input_validation_lambda_image_name}"
  package_type  = "Image"
  timeout       = 600

  environment {
    variables = {
      GRAPHQL_URL = local.graph_ql_url
    }
  }

  vpc_config {
    security_group_ids = [var.security_group_id]
    subnet_ids         = [var.private_subnet_id]
  }

  depends_on = [null_resource.build_and_push_input_validation_lambda_image]
}

# Lambda Function for File Transformation
resource "null_resource" "build_and_push_file_transformer_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = var.ecr_repository_url
      AWS_REGION     = data.aws_region.current_region.name
      IMAGE_NAME = local.s3_file_transformer_lambda_image_name
    }
    command = "${abspath(path.module)}/../../lambda/document-ingestion/s3_file_transformer/src/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "file_transformer_lambda" {
  function_name = "${var.app_prefix}-s3-file-transformer"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = "${var.ecr_repository_url}:${local.s3_file_transformer_lambda_image_name}"
  package_type  = "Image"
  timeout       = 600

  vpc_config {
    security_group_ids = [var.security_group_id]
    subnet_ids         = [var.private_subnet_id]
  }

  environment {
    variables = {
      INPUT_BUCKET  = var.input_assets_bucket_name
      OUTPUT_BUCKET = var.processed_assets_bucket_name
      GRAPHQL_URL   = local.graph_ql_url
    }
  }

  depends_on = [null_resource.build_and_push_file_transformer_lambda_image]
}

# Lambda Function for Embeddings Job
resource "null_resource" "build_and_push_embeddings_job_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = var.ecr_repository_url
      AWS_REGION     = data.aws_region.current_region.name
      IMAGE_NAME = local.embeddings_job_lambda_image_name
    }
    command = "${abspath(path.module)}/../../lambda/document-ingestion/embeddings_job/src/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "embeddings_job_lambda" {
  function_name = "${var.app_prefix}-embeddings-job"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = "${var.ecr_repository_url}:${local.embeddings_job_lambda_image_name}"
  package_type  = "Image"
  timeout       = 600

  vpc_config {
    security_group_ids = [var.security_group_id]
    subnet_ids         = [var.private_subnet_id]
  }

  environment {
    variables = {
      OUTPUT_BUCKET               = var.processed_assets_bucket_name
      GRAPHQL_URL                 = local.graph_ql_url
      INPUT_BUCKET                = var.input_assets_bucket_name
      OPENSEARCH_DOMAIN_ENDPOINT  = local.selected_open_search_endpoint
      OPENSEARCH_INDEX            = var.existing_open_search_index_name
      OPENSEARCH_SECRET_ID        = var.open_search_secret
      OPENSEARCH_API_NAME         = local.open_search_api_name
    }
  }

  depends_on = [null_resource.build_and_push_embeddings_job_lambda_image]
}
