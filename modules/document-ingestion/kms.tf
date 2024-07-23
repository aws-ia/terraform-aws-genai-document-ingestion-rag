resource "aws_kms_key" "ingestion" {
  description         = "KMS key for Document Ingestion sub-module"
  policy              = data.aws_iam_policy_document.ingestion_kms_key.json
  enable_key_rotation = true
}

# Assign an alias to the key
resource "aws_kms_alias" "ingestion" {
  name          = "alias/${var.solution_prefix}-ingestion"
  target_key_id = aws_kms_key.ingestion.key_id
}