# TODO: setup encryption with CME, setup resource policy
resource "aws_cloudwatch_event_bus" "ingestion" {
  name = local.cloudwatch.ingestion_api.event_bus_name
  tags = local.combined_tags
}

# TODO: move to templatefile
resource "aws_cloudwatch_event_rule" "ingestion" {
  name           = local.cloudwatch.ingestion_api.event_bus_name
  description    = "Rule to trigger ingestion state machine"
  event_bus_name = aws_cloudwatch_event_bus.ingestion.name

  event_pattern = <<PATTERN
    {
      "source": ["ingestion"],
      "detail-type": ["genAIdemo"]
    }
  PATTERN

  tags = local.combined_tags
}

resource "aws_cloudwatch_event_target" "ingestion" {
  rule           = aws_cloudwatch_event_rule.ingestion.name
  target_id      = local.cloudwatch.ingestion_sm.event_bridge_target_id
  arn            = aws_sfn_state_machine.ingestion_sm.arn
  role_arn       = aws_iam_role.ingestion_sm_eventbridge.arn
  event_bus_name = aws_cloudwatch_event_bus.ingestion.name
}

resource "aws_cloudwatch_log_group" "ingestion_api" {
  name              = local.cloudwatch.ingestion_api.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ingestion.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "ingestion_sm" {
  name              = local.cloudwatch.ingestion_sm.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ingestion.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "ingestion_input_validation" {
  name              = "/aws/lambda/${aws_lambda_function.ingestion_input_validation.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ingestion.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "file_transformer" {
  name              = "/aws/lambda/${aws_lambda_function.file_transformer.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ingestion.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "embeddings_job" {
  name              = "/aws/lambda/${aws_lambda_function.embeddings_job.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ingestion.arn
  tags              = local.combined_tags
}