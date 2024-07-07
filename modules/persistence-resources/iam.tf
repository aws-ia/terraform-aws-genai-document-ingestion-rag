# resource "aws_iam_role" "appsync_execution_role" {
#   name = "appsync_execution_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "appsync.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "appsync_execution_policy" {
#   name = "appsync_execution_policy"
#   role = aws_iam_role.appsync_execution_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "appsync:*",
#           "logs:*",
#           "cloudwatch:*",
#           "dynamodb:*",
#           "lambda:*"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
