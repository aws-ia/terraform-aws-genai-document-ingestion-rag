# Create an ECR repository
resource "aws_ecr_repository" "app_ecr_repository" {
  name = "${var.app_prefix}_app_ecr_repository"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = aws_kms_key.ecr_kms_key.arn
  }
}

# Manage ECR image versions
resource "aws_ecr_lifecycle_policy" "_app_ecr_repository" {
  repository = aws_ecr_repository.app_ecr_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_kms_key" "ecr_kms_key" {
  description             = "KMS key for encrypting ECR images"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  policy = data.aws_iam_policy_document.ecr_kms_key.json
}
