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

# resource "aws_iam_role" "qa_construct_role" {
#   name               = "${var.app_prefix}-qa_construct_role"
#   assume_role_policy = data.aws_iam_policy_document.qa_construct_log_group_assume_role.json
# }

# resource "aws_iam_role_policy" "qa_construct_role_policy" {
#   name   = "${var.app_prefix}-qa_construct_role_policy"
#   role   = aws_iam_role.qa_construct_role.id
#   policy = data.aws_iam_policy_document.qa_construct_log_group_policy.json
# }

# resource "aws_iam_role" "appsync_logging_assume_role" {
#   name               = "${var.app_prefix}-appsync_logging_assume_role"
#   assume_role_policy = data.aws_iam_policy_document.appsync_logging_assume_role.json
# }
# resource "aws_iam_role_policy_attachment" "appsync_logging_assume_role_attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
#   role       = aws_iam_role.appsync_logging_assume_role.name
# }
# resource "aws_iam_policy" "appsync_logging_publish_policy" {
#   name   = "${var.app_prefix}appsync_logging_publish_policy"
#   policy = data.aws_iam_policy_document.appsync_logging_assume_role_publish_policy.json
# }
# resource "aws_iam_role_policy_attachment" "appsync_logging_assume_role_publish_attachment" {
#   policy_arn = aws_iam_policy.appsync_logging_publish_policy.arn
#   role       = aws_iam_role.appsync_logging_assume_role.name
# }


# resource "aws_iam_role" "job_status_data_source_role" {
#   name               = "${var.app_prefix}-appsync_none_data_datasource_role"
#   assume_role_policy = data.aws_iam_policy_document.job_status_data_source_role.json
# }
# resource "aws_iam_role_policy" "appsync_none_data_datasource_role_policy" {
#   role   = aws_iam_role.job_status_data_source_role.id
#   policy = data.aws_iam_policy_document.job_status_data_source_role_policy.json
# }

# resource "aws_iam_role" "firehose_role" {
#   name = "${var.app_prefix}-firehose_delivery_role"

#   assume_role_policy = data.aws_iam_policy_document.firehose_role.json
# }
# resource "aws_iam_policy" "firehose_to_s3_policy" {
#   name        = "${var.app_prefix}-firehose_to_s3_policy"
#   description = "Allow Firehose to access S3 bucket"

#   policy = data.aws_iam_policy_document.firehose_to_s3_policy.json
# }

# resource "aws_iam_role_policy_attachment" "firehose_policy_attachment" {
#   role       = aws_iam_role.firehose_role.name
#   policy_arn = aws_iam_policy.firehose_to_s3_policy.arn
# }

# // Question answering function role and inline policy
# resource "aws_iam_role" "question_answering_function_role" {
#   name               = "${var.app_prefix}-question_answering-fn-role"
#   assume_role_policy = data.aws_iam_policy_document.question_answering_function_role.json
# }
# resource "aws_iam_role_policy" "question_answering_function_inline_policy" {
#   name   = "${var.app_prefix}-LambdaFunctionServiceRolePolicy"
#   role   = aws_iam_role.question_answering_function_role.id
#   policy = data.aws_iam_policy_document.question_answering_function_inline_policy.json
# }

# resource "aws_iam_policy" "question_answering_function_policy" {
#   name   = "${var.app_prefix}question_answering_function_policy"
#   policy = data.aws_iam_policy_document.question_answering_function_policy.json
# }
# resource "aws_iam_role_policy_attachment" "question_answering_function_attachment" {
#   policy_arn = aws_iam_policy.question_answering_function_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }

# resource "aws_iam_policy" "describe_network_interfaces_policy" {
#   name   = "${var.app_prefix}describe_network_interfaces_policy"
#   policy = data.aws_iam_policy_document.describe_network_interfaces_policy.json
# }
# resource "aws_iam_role_policy_attachment" "describe_network_interfaces_attachment" {
#   policy_arn = aws_iam_policy.describe_network_interfaces_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }

# resource "aws_iam_policy" "open_search_secret_policy" {
#   count  = var.open_search_secret == "NONE" ? 0 : 1
#   name   = "${var.app_prefix}open_search_secret_policy"
#   policy = data.aws_iam_policy_document.open_search_secret_policy_document.json
# }
# resource "aws_iam_role_policy_attachment" "open_search_secret_attachment" {
#   count      = var.open_search_secret == "NONE" ? 0 : 1
#   policy_arn = aws_iam_policy.open_search_secret_policy[0].arn
#   role       = aws_iam_role.question_answering_function_role.name
# }

# // Policies and attachments for S3 read
# resource "aws_iam_policy" "s3_read_policy" {
#   name   = "${var.app_prefix}s3_read_policy"
#   policy = data.aws_iam_policy_document.s3_read_policy.json
# }

# resource "aws_iam_role_policy_attachment" "s3_read_attachment" {
#   policy_arn = aws_iam_policy.s3_read_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }

# // SQS policis
# resource "aws_iam_policy" "sqs_send_message_policy" {
#   name   = "${var.app_prefix}sqs_send_message_policy"
#   policy = data.aws_iam_policy_document.sqs_send_message_policy.json
# }
# resource "aws_iam_role_policy_attachment" "sqs_send_message_attachment" {
#   policy_arn = aws_iam_policy.sqs_send_message_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }

# // Policies and attachments for opensearch access
# resource "aws_iam_policy" "opensearch_access_policy" {
#   name   = "${var.app_prefix}opensearch_access_policy"
#   policy = data.aws_iam_policy_document.opensearch_access_policy.json
# }

# resource "aws_iam_role_policy_attachment" "opensearch_access_attachment" {
#   policy_arn = aws_iam_policy.opensearch_access_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }
# // Policies and attachments for bedrock invoke model
# resource "aws_iam_policy" "bedrock_invoke_model_policy" {
#   name   = "${var.app_prefix}bedrock_invoke_model_policy"
#   policy = data.aws_iam_policy_document.bedrock_invoke_model_policy.json
# }

# resource "aws_iam_role_policy_attachment" "bedrock_invoke_model_attachment" {
#   policy_arn = aws_iam_policy.bedrock_invoke_model_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }
# // Policies and attachments for suppression
# resource "aws_iam_policy" "suppression_policy" {
#   name   = "${var.app_prefix}suppression_policy"
#   policy = data.aws_iam_policy_document.suppression_policy.json
# }
# resource "aws_iam_role_policy_attachment" "suppression_attachment" {
#   policy_arn = aws_iam_policy.suppression_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }
# // Policies and attachments for AppSync
# resource "aws_iam_policy" "appsync_policy" {
#   name   = "${var.app_prefix}AppSyncPolicy"
#   policy = data.aws_iam_policy_document.appsync_policy.json
# }

# resource "aws_iam_role_policy_attachment" "appsync_policy_attachment" {
#   policy_arn = aws_iam_policy.appsync_policy.arn
#   role       = aws_iam_role.question_answering_function_role.name
# }

# resource "aws_iam_service_linked_role" "opensearch_service_linked_role" {
#   aws_service_name = "opensearchservice.amazonaws.com"
# }
