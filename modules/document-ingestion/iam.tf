resource "aws_iam_role" "ingestion_construct_role" {
  name = "ingestionConstructRole"
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
    name = "ingestionConstructRole_inline"
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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
  ]
}

resource "aws_iam_policy" "eventbridge_put_events_policy" {
  name = "eventbridgePutEventsPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "events:PutEvents",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eventbridge_policy" {
  role       = aws_iam_role.ingestion_construct_role.name
  policy_arn = aws_iam_policy.eventbridge_put_events_policy.arn
}

# IAM Role for AppSync Logs
resource "aws_iam_role" "appsync_logs_role" {
  name = "AppSyncLogsRole"
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

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.app_prefix}-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "lambda-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses",
            "ec2:DescribeNetworkInterfaces"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "s3:GetObject",
            "s3:GetObject*",
            "s3:GetBucket*",
            "s3:List*",
            "s3:PutObjectRetention",
            "s3:List*",
            "s3:GetBucket*",
            "s3:Abort*",
            "s3:DeleteObject*",
            "s3:PutObjectLegalHold",
            "s3:PutObjectTagging",
            "s3:PutObjectVersionTagging",
            "s3:PutObject",
            "s3:GetObject*"
          ]
          Effect   = "Allow"
          Resource = [
            var.input_assets_bucket_arn,
            "${var.input_assets_bucket_arn}/*",
            var.processed_assets_bucket_arn,
            "${var.processed_assets_bucket_arn}/*"
          ]
        },
        {
          Action = [
            "appsync:GraphQL"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:appsync:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:apis/${aws_appsync_graphql_api.ingestion_graphql_api.id}/*"
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability"
          ]
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role" "sfn_role" {
  name = "sfn-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "sfn-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "lambda:InvokeFunction"
          ]
          Effect   = "Allow"
          Resource = [
            aws_lambda_function.input_validation_lambda.arn,
            aws_lambda_function.file_transformer_lambda.arn,
            aws_lambda_function.embeddings_job_lambda.arn
          ]
        },
        {
          Action = [
            "logs:CreateLogDelivery",
            "logs:CreateLogStream",
            "logs:GetLogDelivery",
            "logs:UpdateLogDelivery",
            "logs:DeleteLogDelivery",
            "logs:ListLogDeliveries",
            "logs:PutLogEvents",
            "logs:PutResourcePolicy",
            "logs:DescribeResourcePolicies",
            "logs:DescribeLogGroups",
            "xray:PutTraceSegments",
            "xray:PutTelemetryRecords",
            "xray:GetSamplingRules",
            "xray:GetSamplingTargets"
          ],
          Effect = "Allow"
          Resource = ["*"]
        },
        {
          Effect = "Allow",
          Action = [
            "states:StartExecution"
          ],
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role" "eventbridge_sfn_role" {
  name = "eventbridge-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSStepFunctionsConsoleFullAccess"]
}
