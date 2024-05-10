// Appsync role and policy attachment
resource "aws_iam_role" "appsync_service_role" {
  name               = "${var.prefix}_iam_appsync_role"
  assume_role_policy = data.aws_iam_policy_document.appsync_service_role.json
}

resource "aws_iam_role_policy_attachment" "appsync_service_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncInvokeFullAccess"
  role       = aws_iam_role.appsync_service_role.name
}

// Question answering function role and inline policy
resource "aws_iam_role" "question_answering_function_role" {
  name               = "question_answering_function_role"
  assume_role_policy = data.aws_iam_policy_document.question_answering_assume_role.json
}

resource "aws_iam_role_policy" "question_answering_function_inline_policy" {
  name   = "LambdaFunctionServiceRolePolicy"
  role   = aws_iam_role.question_answering_function_role.id
  policy = data.aws_iam_policy_document.question_answering_inline_policy.json
}

// Policies and attachments for the question answering function
resource "aws_iam_policy" "question_answering_function_policy" {
  name   = "question_answering_function_policy"
  policy = data.aws_iam_policy_document.question_answering_function_policy.json
}

resource "aws_iam_role_policy_attachment" "question_answering_function_attachment" {
  policy_arn = aws_iam_policy.question_answering_function_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// Policies and attachments for network interfaces
resource "aws_iam_policy" "describe_network_interfaces_policy" {
  name   = "describe_network_interfaces_policy"
  policy = data.aws_iam_policy_document.describe_network_interfaces_policy.json
}

resource "aws_iam_role_policy_attachment" "describe_network_interfaces_attachment" {
  policy_arn = aws_iam_policy.describe_network_interfaces_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// Policies and attachments for open search secret
resource "aws_iam_policy" "open_search_secret_policy" {
  name   = "open_search_secret_policy"
  policy = data.aws_iam_policy_document.open_search_secret_policy_document.json
}

resource "aws_iam_role_policy_attachment" "open_search_secret_attachment" {
  policy_arn = aws_iam_policy.open_search_secret_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// Policies and attachments for S3 read
resource "aws_iam_policy" "s3_read_policy" {
  name   = "s3_read_policy"
  policy = data.aws_iam_policy_document.s3_read_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_read_attachment" {
  policy_arn = aws_iam_policy.s3_read_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// Policies and attachments for opensearch access
resource "aws_iam_policy" "opensearch_access_policy" {
  name   = "opensearch_access_policy"
  policy = data.aws_iam_policy_document.opensearch_access_policy.json
}

resource "aws_iam_role_policy_attachment" "opensearch_access_attachment" {
  policy_arn = aws_iam_policy.opensearch_access_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// Policies and attachments for bedrock invoke model
resource "aws_iam_policy" "bedrock_invoke_model_policy" {
  name   = "bedrock_invoke_model_policy"
  policy = data.aws_iam_policy_document.bedrock_invoke_model_policy.json
}

resource "aws_iam_role_policy_attachment" "bedrock_invoke_model_attachment" {
  policy_arn = aws_iam_policy.bedrock_invoke_model_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// Policies and attachments for suppression
resource "aws_iam_policy" "suppression_policy" {
  name   = "suppression_policy"
  policy = data.aws_iam_policy_document.suppression_policy.json
}

resource "aws_iam_role_policy_attachment" "suppression_attachment" {
  policy_arn = aws_iam_policy.suppression_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// Policies and attachments for AppSync
resource "aws_iam_policy" "appsync_policy" {
  name   = "AppSyncPolicy"
  policy = data.aws_iam_policy_document.appsync_policy.json
}

resource "aws_iam_role_policy_attachment" "appsync_policy_attachment" {
  policy_arn = aws_iam_policy.appsync_policy.arn
  role       = aws_iam_role.question_answering_function_role.name
}

// QA construct role
resource "aws_iam_role" "qa_construct_role" {
  name               = "qaConstructRole"
  assume_role_policy = data.aws_iam_policy_document.qa_construct_role.json
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "firehose_to_s3_policy" {
  name        = "firehose_to_s3_policy"
  description = "Allow Firehose to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_s3_bucket.waf_logs.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attachment" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_to_s3_policy.arn
}
