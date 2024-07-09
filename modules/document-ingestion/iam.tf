############################################################################################################
# IAM Role for AppSync Ingestion API CloudWatch Log
############################################################################################################
resource "aws_iam_role" "ingestion_api_log" {
  name = local.graphql.ingestion_api.cloudwatch_log_role_name

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

resource "aws_iam_role_policy" "ingestion_api_log" {
  name   = local.graphql.ingestion_api.cloudwatch_log_role_name
  role   = aws_iam_role.ingestion_api_log.id
  policy = data.aws_iam_policy_document.ingestion_api_log.json
}

############################################################################################################
# IAM Role for AppSync Ingestion API Data Source
############################################################################################################
resource "aws_iam_role" "ingestion_api_datasource" {
  name = local.graphql.ingestion_api.name

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

resource "aws_iam_role_policy" "ingestion_api_datasource" {
  name   = local.graphql.ingestion_api.name
  role   = aws_iam_role.ingestion_api_datasource.id
  policy = data.aws_iam_policy_document.ingestion_api_datasource.json
}

############################################################################################################
# IAM Role for Ingestion Input Validation Lambda
############################################################################################################

resource "aws_iam_role" "ingestion_input_validation" {
  name = local.lambda.ingestion_input_validation.name
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

resource "aws_iam_role_policy" "ingestion_input_validation" {
  name   = local.lambda.ingestion_input_validation.name
  role   = aws_iam_role.ingestion_input_validation.id
  policy = data.aws_iam_policy_document.ingestion_input_validation.json
}

############################################################################################################
# IAM Role for File Transformer Lambda
############################################################################################################

resource "aws_iam_role" "file_transformer" {
  name = local.lambda.file_transformer.name
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

resource "aws_iam_role_policy" "file_transformer" {
  name   = local.lambda.file_transformer.name
  role   = aws_iam_role.file_transformer.id
  policy = data.aws_iam_policy_document.file_transformer.json
}

############################################################################################################
# IAM Role for Embeddings Job Lambda
############################################################################################################

resource "aws_iam_role" "embeddings_job" {
  name = local.lambda.embeddings_job.name
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

resource "aws_iam_role_policy" "embeddings_job" {
  name   = local.lambda.embeddings_job.name
  role   = aws_iam_role.embeddings_job.id
  policy = data.aws_iam_policy_document.embeddings_job.json
}

# resource "aws_iam_policy" "eventbridge_put_events_policy" {
#   name = "eventbridgePutEventsPolicy"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = "events:PutEvents",
#       Resource = "*"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_eventbridge_policy" {
#   role       = aws_iam_role.ingestion_construct_role.name
#   policy_arn = aws_iam_policy.eventbridge_put_events_policy.arn
# }


# resource "aws_iam_role" "sfn_role" {
#   name = "sfn-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = {
#         Service = "states.amazonaws.com"
#       }
#     }]
#   })

#   inline_policy {
#     name = "sfn-policy"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action = [
#             "lambda:InvokeFunction"
#           ]
#           Effect   = "Allow"
#           Resource = [
#             aws_lambda_function.input_validation_lambda.arn,
#             aws_lambda_function.file_transformer_lambda.arn,
#             aws_lambda_function.embeddings_job_lambda.arn
#           ]
#         },
#         {
#           Action = [
#             "logs:CreateLogDelivery",
#             "logs:CreateLogStream",
#             "logs:GetLogDelivery",
#             "logs:UpdateLogDelivery",
#             "logs:DeleteLogDelivery",
#             "logs:ListLogDeliveries",
#             "logs:PutLogEvents",
#             "logs:PutResourcePolicy",
#             "logs:DescribeResourcePolicies",
#             "logs:DescribeLogGroups",
#             "xray:PutTraceSegments",
#             "xray:PutTelemetryRecords",
#             "xray:GetSamplingRules",
#             "xray:GetSamplingTargets"
#           ],
#           Effect = "Allow"
#           Resource = ["*"]
#         },
#         {
#           Effect = "Allow",
#           Action = [
#             "states:StartExecution"
#           ],
#           Resource = "*"
#         },
#       ]
#     })
#   }
# }

# resource "aws_iam_role" "eventbridge_sfn_role" {
#   name = "eventbridge-sfn-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "events.amazonaws.com"
#         },
#         "Action": "sts:AssumeRole"
#       }
#     ]
#   })

#   managed_policy_arns = ["arn:aws:iam::aws:policy/AWSStepFunctionsConsoleFullAccess"]
# }
