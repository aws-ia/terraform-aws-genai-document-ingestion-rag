# Lambda Function for Input Validation
# Build and push Docker image to ECR
resource "null_resource" "build_and_push_input_validation_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = aws_ecr_repository.input_validation_lambda.repository_url
      AWS_REGION     = data.aws_region.current_region.name
    }
    command = "${abspath(path.module)}/../../lambda/document-ingestion/input_validation/src/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "input_validation_lambda" {
  function_name    = "${var.app_prefix}ingestion_input_validation"
  role             = aws_iam_role.lambda_exec_role.arn
  image_uri     = "${aws_ecr_repository.input_validation_lambda.repository_url}:latest"
  package_type  = "Image"
  environment {
    variables = {
      GRAPHQL_URL = aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"]
    }
  }
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = var.security_groups_ids
  }
}

# Lambda Function for File Transformation
resource "null_resource" "build_and_push_file_transformer_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = aws_ecr_repository.file_transformer_lambda.repository_url
      AWS_REGION     = data.aws_region.current_region.name
    }
    command = "${abspath(path.module)}/../../lambda/document-ingestion/s3_file_transformer/src/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "file_transformer_lambda" {
  function_name    = "${var.app_prefix}_s3_file_transformer_docker"
  role             = aws_iam_role.lambda_exec_role.arn
  image_uri     = "${aws_ecr_repository.file_transformer_lambda.repository_url}:latest"
  package_type  = "Image"
  environment {
    variables = {
      INPUT_BUCKET  = var.input_assets_bucket_name
      OUTPUT_BUCKET = var.processed_assets_bucket_name
      GRAPHQL_URL   = aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"]
    }
  }
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = var.security_groups_ids
  }
}

# Lambda Function for Embeddings Job
resource "null_resource" "build_and_push_embeddings_job_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = aws_ecr_repository.embeddings_job_lambda.repository_url
      AWS_REGION     = data.aws_region.current_region.name
    }
    command = "${abspath(path.module)}/../../lambda/document-ingestion/embeddings_job/src/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "embeddings_job_lambda" {
  function_name    = "${var.app_prefix}_embeddings_job_docker"
  role             = aws_iam_role.lambda_exec_role.arn
  image_uri     = "${aws_ecr_repository.embeddings_job_lambda.repository_url}:latest"
  package_type  = "Image"
  environment {
    variables = {
      OUTPUT_BUCKET           = var.processed_assets_bucket_name
      GRAPHQL_URL             = aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"]
      INPUT_BUCKET               = var.input_assets_bucket_name
      OPENSEARCH_DOMAIN_ENDPOINT = local.selected_open_search_endpoint
      OPENSEARCH_INDEX           = var.existing_open_search_index_name
      OPENSEARCH_SECRET_ID       = var.open_search_secret
    }
  }
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = var.security_groups_ids
  }
}
