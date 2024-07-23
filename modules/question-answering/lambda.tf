############################################################################################################
# Question Answering Lambda
############################################################################################################

module "docker_image_question_answering" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.7.0"

  ecr_repo      = var.ecr_repository_id
  use_image_tag = true
  image_tag     = local.lambda.question_answering.docker_image_tag
  source_path   = local.lambda.question_answering.source_path
  platform      = local.lambda.question_answering.platform

  triggers = {
    dir_sha = local.lambda.question_answering.dir_sha
  }
}

resource "aws_lambda_function" "question_answering" {
  function_name = local.lambda.question_answering.name
  description   = local.lambda.question_answering.description
  role          = aws_iam_role.question_answering.arn
  image_uri     = module.docker_image_question_answering.image_uri
  package_type  = "Image"
  architectures = [local.lambda.question_answering.runtime_architecture]
  timeout       = local.lambda.question_answering.timeout
  memory_size   = local.lambda.question_answering.memory_size
  vpc_config {
    subnet_ids         = local.lambda.question_answering.vpc_config.subnet_ids
    security_group_ids = local.lambda.question_answering.vpc_config.security_group_ids
  }
  environment {
    variables = local.lambda.question_answering.environment.variables
  }

  tags = local.combined_tags
}

resource "aws_lambda_permission" "question_answering" {
  statement_id  = "AllowEventBridgeToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.question_answering.arn
}