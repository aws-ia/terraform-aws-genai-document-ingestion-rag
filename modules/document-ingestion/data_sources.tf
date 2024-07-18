data "aws_region" "current_region" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_kms_key" {
  statement {
    actions = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_exec_role.arn]
    }
  }

  statement {
    sid    = "AllowAccessForKeyAdministrators"
    actions = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
