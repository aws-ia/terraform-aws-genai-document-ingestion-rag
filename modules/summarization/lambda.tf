resource "aws_sqs_queue" "dlq" {
  name = "${var.app_prefix}_summarisation_dlq"
  sqs_managed_sse_enabled = true
}

# Lambda function used to validate inputs in the step function
resource "null_resource" "build_and_push_input_validator_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = var.ecr_repository_url
      AWS_REGION     = data.aws_region.current_region.name
      IMAGE_NAME     = local.summary_input_validator_lambda_image_name
    }
    command = "${abspath(path.module)}/../../lambda/summarization/input_validator/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "input_validation_lambda" {
  function_name = "${var.app_prefix}_${local.summary_input_validator_lambda_image_name}"
  role          = aws_iam_role.lambda_shared_role.arn
  image_uri     = "${var.ecr_repository_url}:${local.summary_input_validator_lambda_image_name}"
  package_type  = "Image"
  description   = "Lambda function to validate input for summary api"

  environment {
    variables = {
      GRAPHQL_URL = aws_appsync_graphql_api.summarization_graphql_api.uris["GRAPHQL"]
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_groups_ids
  }

  memory_size = 1769
  timeout     = 300

  tracing_config {
    mode = "Active"
  }

  depends_on = [null_resource.build_and_push_input_validator_lambda_image]
}

# Lambda function used to read documents in the step function
resource "null_resource" "build_and_push_document_reader_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = var.ecr_repository_url
      AWS_REGION     = data.aws_region.current_region.name
      IMAGE_NAME     = local.document_reader_lambda_image_name
    }
    command = "${abspath(path.module)}/../../lambda/summarization/document_reader/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "document_reader_lambda" {
  function_name = "${var.app_prefix}_${local.document_reader_lambda_image_name}"
  role          = aws_iam_role.lambda_shared_role.arn
  image_uri     = "${var.ecr_repository_url}:${local.document_reader_lambda_image_name}"
  package_type  = "Image"
  description   = "Lambda function to read the input transformed document"

  environment {
    variables = {
      TRANSFORMED_ASSET_BUCKET = var.processed_assets_bucket_name
      INPUT_ASSET_BUCKET       = var.input_assets_bucket_name
      IS_FILE_TRANSFORMED      = var.is_file_transformation_required
      GRAPHQL_URL              = aws_appsync_graphql_api.summarization_graphql_api.uris["GRAPHQL"]
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_groups_ids
  }

  memory_size = 1769
  timeout     = 300

  tracing_config {
    mode = "Active"
  }

  depends_on = [null_resource.build_and_push_document_reader_lambda_image]
}

# Lambda function used to generate the summary in the step function
resource "null_resource" "build_and_push_generate_summary_lambda_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      REPOSITORY_URL = var.ecr_repository_url
      AWS_REGION     = data.aws_region.current_region.name
      IMAGE_NAME     = local.generate_summary_lambda_image_name
    }
    command = "${abspath(path.module)}/../../lambda/summarization/summary_generator/build_push_docker.sh"
  }
}

resource "aws_lambda_function" "generate_summary_lambda" {
  function_name = "${var.app_prefix}generate_summary_lambda"
  role          = aws_iam_role.lambda_shared_role.arn
  image_uri     = "${var.ecr_repository_url}:${local.generate_summary_lambda_image_name}"
  package_type  = "Image"
  description   = "Lambda function to generate the summary"

  environment {
    variables = {
      ASSET_BUCKET_NAME       = var.processed_assets_bucket_name
      GRAPHQL_URL             = aws_appsync_graphql_api.summarization_graphql_api.uris["GRAPHQL"]
      SUMMARY_LLM_CHAIN_TYPE  = local.summary_chain_type
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_groups_ids
  }

  memory_size = 1769
  timeout     = 600

  tracing_config {
    mode = "Active"
  }

  depends_on = [null_resource.build_and_push_generate_summary_lambda_image]
}
