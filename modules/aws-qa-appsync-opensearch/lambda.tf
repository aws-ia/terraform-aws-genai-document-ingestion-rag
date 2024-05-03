# Create an ECR repository
resource "aws_ecr_repository" "question_answering_function" {
  name = "question_answering_function-${var.stage}"
}

# Build and push Docker image to ECR
resource "null_resource" "build_and_push_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Build Docker image
      docker build -t ${aws_ecr_repository.question_answering_function.repository_url}:latest .
      # Authenticate Docker with ECR
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.question_answering_function.registry_id}.dkr.ecr.your-region.amazonaws.com
      # Push Docker image to ECR
      docker push ${aws_ecr_repository.question_answering_function.repository_url}:latest
    EOT
  }
}

# Create Lambda function using Docker image from ECR
resource "aws_lambda_function" "question_answering_function" {
  function_name    = "question_answering_function"
  role             = aws_iam_role.question_answering_function_role.arn
  handler          = "not_required_for_containers"
  runtime          = "provided.al2"
  timeout          = 900
  memory_size      = 1024
  image_uri        = "${aws_ecr_repository.question_answering_function.repository_url}:latest"
  vpc_config {
    security_group_ids = [local.security_group_id]
    subnet_ids         = [aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      GRAPHQL_URL = aws_appsync_graphql_api.question_answering_graphql_api.uris["GRAPHQL"]
      INPUT_BUCKET = aws_s3_bucket.input_assets_qa_bucket.bucket
      OPENSEARCH_DOMAIN_ENDPOINT = var.existing_opensearch_domain.endpoint
      OPENSEARCH_INDEX = var.open_search_index_name
      OPENSEARCH_SECRET_ID = local.secret_id
    }
  }

  depends_on = [null_resource.build_and_push_image]
}

resource "aws_lambda_permission" "grant_invoke_lambda" {
  statement_id  = "AllowAppSyncToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering_function.arn
  principal     = "appsync.amazonaws.com"
  source_arn    = aws_appsync_datasource.event_bridge_datasource.arn
}
