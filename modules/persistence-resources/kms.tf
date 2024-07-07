resource "aws_kms_key" "app_kms_key" {
  description             = "KMS key for ${var.solution_prefix}"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.app_kms_key.json
}

resource "aws_kms_alias" "app_kms_key" {
  name          = "alias/${var.solution_prefix}"
  target_key_id = aws_kms_key.app_kms_key.key_id
}