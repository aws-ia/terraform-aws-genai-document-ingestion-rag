resource "aws_iam_role" "summarization_construct_role" {
  name = "${var.app_prefix}-summarization_construct_role"
  assume_role_policy = data.aws_iam_policy_document.summarization_construct_role.json
}

resource "aws_iam_role" "summarization_appsync_logs_role" {
  name = "SummarizationAppSyncLogsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "appsync.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "appsync-logs-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
      }]
    })
  }
}

# Lambda shared role
resource "aws_iam_role" "lambda_shared_role" {
  name = "${var.app_prefix}-lambda-shared-role"

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
}

resource "aws_iam_role_policy" "shared_lambda_function_service_role_policy" {
  name = "${var.app_prefix}-shared-lambda-role-policy"
  role = aws_iam_role.lambda_shared_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:PutObject",
          "appsync:GraphQL",
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "rekognition:DetectModerationLabels"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${var.input_assets_bucket_name}/*",
          "arn:${data.aws_partition.current.partition}:s3:::${var.processed_assets_bucket_name}/*",
          "arn:${data.aws_partition.current.partition}:appsync:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:apis/${local.update_graphql_api_id}/*",
          "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current_region.name}::foundation-model/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "sfn_role" {
  name = "sfn_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "sfn_policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "lambda:InvokeFunction",
            "sqs:SendMessage",
            "logs:*"
          ],
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "${var.app_prefix}-summarization_firehose_delivery_role"

  assume_role_policy = data.aws_iam_policy_document.firehose_role.json
}
