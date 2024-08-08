# TODO: setup resource policy, DLQ
resource "awscc_events_event_bus" "summarization" {
  name               = local.cloudwatch.summarization_api.event_bus_name
  kms_key_identifier = aws_kms_alias.summarization.arn
  tags = [
    for k, v in local.combined_tags :
    {
      key : k,
      value : v
    }
  ]
}

# TODO: move to templatefile
resource "aws_cloudwatch_event_rule" "summarization" {
  name           = local.cloudwatch.summarization_api.event_bus_name
  description    = "Rule to trigger summarization state machine"
  event_bus_name = awscc_events_event_bus.summarization.name

  event_pattern = <<PATTERN
    {
      "source": ["summary"],
      "detail-type": ["genAIdemo"]
    }
  PATTERN

  tags = local.combined_tags
}

resource "aws_cloudwatch_event_target" "summarization" {
  rule           = aws_cloudwatch_event_rule.summarization.name
  target_id      = local.cloudwatch.summarization_sm.event_bridge_target_id
  arn            = aws_sfn_state_machine.summarization_sm.arn
  role_arn       = aws_iam_role.summarization_sm_eventbridge.arn
  event_bus_name = awscc_events_event_bus.summarization.name
  dead_letter_config {
    arn = aws_sqs_queue.summarization_sm_dlq.arn
  }
}

resource "aws_cloudwatch_log_group" "summarization_api" {
  name              = local.cloudwatch.summarization_api.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_alias.summarization.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "summarization_sm" {
  name              = local.cloudwatch.summarization_sm.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_alias.summarization.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "summarization_input_validation" {
  name              = local.lambda.summarization_input_validation.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_alias.summarization.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "summarization_doc_reader" {
  name              = local.lambda.summarization_doc_reader.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_alias.summarization.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "summarization_generator" {
  name              = local.lambda.summarization_generator.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_alias.summarization.arn
  tags              = local.combined_tags
}
