############################################################################################################
# IAM Role for AppSync Question Answering API CloudWatch Log
############################################################################################################
resource "aws_iam_role" "question_answering_api_log" {
  name = local.graphql.question_answering_api.cloudwatch_log_role_name

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

resource "aws_iam_role_policy" "question_answering_api_log" {
  name   = local.graphql.question_answering_api.cloudwatch_log_role_name
  role   = aws_iam_role.question_answering_api_log.id
  policy = data.aws_iam_policy_document.question_answering_api_log.json
}

############################################################################################################
# IAM Role for AppSync Question Answering API Data source
############################################################################################################
resource "aws_iam_role" "question_answering_api_event_bridge_datasource" {
  name = local.graphql.question_answering_api.event_bridge_datasource_name

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

resource "aws_iam_role_policy" "question_answering_api_event_bridge_datasource" {
  name   = local.graphql.question_answering_api.event_bridge_datasource_name
  role   = aws_iam_role.question_answering_api_event_bridge_datasource.id
  policy = data.aws_iam_policy_document.question_answering_api_event_bridge_datasource.json
}

############################################################################################################
# IAM Role for Question Answering Lambda
############################################################################################################

resource "aws_iam_role" "question_answering" {
  name = local.lambda.question_answering.name
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

resource "aws_iam_role_policy" "question_answering" {
  name   = local.lambda.question_answering.name
  role   = aws_iam_role.question_answering.id
  policy = data.aws_iam_policy_document.question_answering.json
}