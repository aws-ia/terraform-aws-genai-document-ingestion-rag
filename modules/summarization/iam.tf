############################################################################################################
# IAM Role for AppSync Summarization API CloudWatch Log
############################################################################################################
resource "aws_iam_role" "summarization_api_log" {
  name = local.graphql.summarization_api.cloudwatch_log_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "appsync.amazonaws.com"
      }
    }]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "summarization_api_log" {
  name   = local.graphql.summarization_api.cloudwatch_log_role_name
  role   = aws_iam_role.summarization_api_log.id
  policy = data.aws_iam_policy_document.summarization_api_log.json
}

############################################################################################################
# IAM Role for AppSync Summarization API Data Source
############################################################################################################
resource "aws_iam_role" "summarization_api_datasource" {
  name = local.graphql.summarization_api.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "appsync.amazonaws.com"
      }
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
  ]

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "summarization_api_datasource" {
  name   = local.graphql.summarization_api.name
  role   = aws_iam_role.summarization_api_datasource.id
  policy = data.aws_iam_policy_document.summarization_api_datasource.json
}

############################################################################################################
# IAM Role for Summarization State Machine
############################################################################################################

resource "aws_iam_role" "summarization_sm" {
  name = local.statemachine.summarization.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "summarization_sm" {
  name   = local.statemachine.summarization.name
  role   = aws_iam_role.summarization_sm.id
  policy = data.aws_iam_policy_document.summarization_sm.json
}

############################################################################################################
# IAM Role for Event Bridge target - Summarization State Machine
############################################################################################################

resource "aws_iam_role" "summarization_sm_eventbridge" {
  name = "${local.statemachine.summarization.name}-eventbridge"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "summarization_sm_eventbridge" {
  name   = "${local.statemachine.summarization.name}-eventbridge"
  role   = aws_iam_role.summarization_sm_eventbridge.id
  policy = data.aws_iam_policy_document.summarization_sm_eventbridge.json
}

############################################################################################################
# IAM Role for Summarization Input Validation Lambda
############################################################################################################

resource "aws_iam_role" "summarization_input_validation" {
  name = local.lambda.summarization_input_validation.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "summarization_input_validation" {
  name   = local.lambda.summarization_input_validation.name
  role   = aws_iam_role.summarization_input_validation.id
  policy = data.aws_iam_policy_document.summarization_input_validation.json
}

############################################################################################################
# IAM Role for Summarization Doc Reader Lambda
############################################################################################################

resource "aws_iam_role" "summarization_doc_reader" {
  name = local.lambda.summarization_doc_reader.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "summarization_doc_reader" {
  name   = local.lambda.summarization_doc_reader.name
  role   = aws_iam_role.summarization_doc_reader.id
  policy = data.aws_iam_policy_document.summarization_doc_reader.json
}

############################################################################################################
# IAM Role for Summarization Generator Lambda
############################################################################################################

resource "aws_iam_role" "summarization_generator" {
  name = local.lambda.summarization_generator.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "summarization_generator" {
  name   = local.lambda.summarization_generator.name
  role   = aws_iam_role.summarization_generator.id
  policy = data.aws_iam_policy_document.summarization_generator.json
}


# resource "aws_iam_role" "firehose_role" {
#   name = "${var.app_prefix}-summarization_firehose_delivery_role"

#   assume_role_policy = data.aws_iam_policy_document.firehose_role.json
# }