resource "aws_ecr_repository" "app_ecr_repository" {
  name = local.ecr.repository_name

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_alias.app_kms_key.target_key_arn
  }
}

resource "aws_ecr_lifecycle_policy" "app_ecr_repository" {
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
