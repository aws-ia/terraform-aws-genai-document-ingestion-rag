resource "aws_kms_key" "persistent_resources" {
  description         = "KMS key for ${var.solution_prefix}"
  policy              = data.aws_iam_policy_document.persistent_resources_kms_key.json
  enable_key_rotation = true
  tags                = local.combined_tags
}

resource "aws_kms_alias" "persistent_resources" {
  name          = "alias/${var.solution_prefix}-persistent-resources"
  target_key_id = aws_kms_key.persistent_resources.key_id
}