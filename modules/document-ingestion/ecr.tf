# resource "aws_kms_key" "ecr_kms_key" {
#   description             = "KMS key for encrypting ECR images"
#   enable_key_rotation     = true
#   deletion_window_in_days = 10
#   policy = data.aws_iam_policy_document.ecr_kms_key.json
# }
#
# # Input validation function repository
# resource "aws_ecr_repository" "input_validation_lambda" {
#   name = "${var.app_prefix}input_validation_lambda"
#   image_tag_mutability = "MUTABLE"
#
#   image_scanning_configuration {
#     scan_on_push = true
#   }
#
#   encryption_configuration {
#     encryption_type = "KMS"
#     kms_key = aws_kms_key.ecr_kms_key.arn
#   }
# }
#
# resource "aws_ecr_lifecycle_policy" "input_validation_lambda" {
#   repository = aws_ecr_repository.input_validation_lambda.name
#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1
#         description  = "Keep last 10 images"
#         selection = {
#           tagStatus   = "untagged"
#           countType   = "imageCountMoreThan"
#           countNumber = 10
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
# }
#
# # File transformer function repository
# resource "aws_ecr_repository" "file_transformer_lambda" {
#   name = "${var.app_prefix}file_transformer_lambda"
#   image_tag_mutability = "MUTABLE"
#
#   image_scanning_configuration {
#     scan_on_push = true
#   }
#
#   encryption_configuration {
#     encryption_type = "KMS"
#     kms_key = aws_kms_key.ecr_kms_key.arn
#   }
# }
#
# resource "aws_ecr_lifecycle_policy" "file_transformer_lambda" {
#   repository = aws_ecr_repository.file_transformer_lambda.name
#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1
#         description  = "Keep last 10 images"
#         selection = {
#           tagStatus   = "untagged"
#           countType   = "imageCountMoreThan"
#           countNumber = 10
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
# }
#
# # Embeddings job lambda repository
# resource "aws_ecr_repository" "embeddings_job_lambda" {
#   name = "${var.app_prefix}embeddings_job_lambda"
#   image_tag_mutability = "MUTABLE"
#
#   image_scanning_configuration {
#     scan_on_push = true
#   }
#
#   encryption_configuration {
#     encryption_type = "KMS"
#     kms_key = aws_kms_key.ecr_kms_key.arn
#   }
# }
#
# resource "aws_ecr_lifecycle_policy" "embeddings_job_lambda" {
#   repository = aws_ecr_repository.embeddings_job_lambda.name
#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1
#         description  = "Keep last 10 images"
#         selection = {
#           tagStatus   = "untagged"
#           countType   = "imageCountMoreThan"
#           countNumber = 10
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
# }
