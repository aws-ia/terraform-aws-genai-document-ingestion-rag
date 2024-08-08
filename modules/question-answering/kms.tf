resource "aws_kms_key" "question_answering" {
  description         = "KMS key for Document Question Answering sub-module"
  policy              = data.aws_iam_policy_document.question_answering_kms_key.json
  enable_key_rotation = true
  tags                = local.combined_tags
}

resource "aws_kms_alias" "question_answering" {
  name          = "alias/${var.solution_prefix}-qa"
  target_key_id = aws_kms_key.question_answering.key_id
}
