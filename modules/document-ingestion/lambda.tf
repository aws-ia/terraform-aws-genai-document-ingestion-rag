# Lambda Function for Input Validation
resource "aws_lambda_function" "input_validation_lambda" {
  filename         = "path/to/lambda.zip"
  function_name    = "ingestion_input_validation_docker-${var.stage}"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
  memory_size      = 1769 * 4
  timeout          = 900
  environment {
    variables = {
      GRAPHQL_URL = aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"]
    }
  }
  vpc_config {
    subnet_ids         = aws_subnet.private.ids
    security_group_ids = [aws_security_group.this.id]
  }
}

# Lambda Function for File Transformation
resource "aws_lambda_function" "file_transformer_lambda" {
  filename         = "path/to/lambda.zip"
  function_name    = "s3_file_transformer_docker-${var.stage}"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
  memory_size      = 1769 * 4
  timeout          = 900
  environment {
    variables = {
      INPUT_BUCKET  = aws_s3_bucket.input_assets_bucket.bucket
      OUTPUT_BUCKET = aws_s3_bucket.processed_assets_bucket.bucket
      GRAPHQL_URL   = aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"]
    }
  }
  vpc_config {
    subnet_ids         = aws_subnet.private.ids
    security_group_ids = [aws_security_group.this.id]
  }
}

# Lambda Function for Embeddings Job
resource "aws_lambda_function" "embeddings_job_lambda" {
  filename         = "path/to/lambda.zip"
  function_name    = "embeddings_job_docker-${var.stage}"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
  memory_size      = 1769 * 4
  timeout          = 900
  environment {
    variables = {
      OUTPUT_BUCKET           = aws_s3_bucket.processed_assets_bucket.bucket
      GRAPHQL_URL             = aws_appsync_graphql_api.ingestion_graphql_api.uris["GRAPHQL"]
      OPENSEARCH_INDEX        = var.open_search_index_name
      OPENSEARCH_API_NAME     = var.open_search_api_name
      OPENSEARCH_DOMAIN_ENDPOINT = var.open_search_domain_endpoint
      OPENSEARCH_SECRET_ID    = var.open_search_secret_id
    }
  }
  vpc_config {
    subnet_ids         = aws_subnet.private.ids
    security_group_ids = [aws_security_group.this.id]
  }
}
