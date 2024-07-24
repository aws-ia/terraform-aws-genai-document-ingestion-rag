resource "aws_kms_key" "summarization" {
  description         = "KMS key for Summarization sub-module"
  policy              = data.aws_iam_policy_document.summarization_kms_key.json
  enable_key_rotation = true
}

resource "aws_kms_alias" "summarization" {
  name          = "alias/${var.solution_prefix}-summarization"
  target_key_id = aws_kms_key.summarization.key_id
}