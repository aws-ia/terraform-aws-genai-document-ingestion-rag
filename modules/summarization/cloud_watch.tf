resource "aws_cloudwatch_event_bus" "summarization" {
  name = local.cloudwatch.summarization.event_bus_name
  tags = local.combined_tags
}

# TODO: move to templatefile
resource "aws_cloudwatch_event_rule" "summarization" {
  name           = local.cloudwatch.summarization.event_bus_name
  description    = "Rule to trigger summarization state machine"
  event_bus_name = aws_cloudwatch_event_bus.summarization.name

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
  event_bus_name = aws_cloudwatch_event_bus.summarization.name
  dead_letter_config {
    arn = aws_sqs_queue.summarization_sm_dlq.arn
  }
}

# TODO: add KMS key
resource "aws_cloudwatch_log_group" "summarization_sm" {
  name              = local.cloudwatch.summarization_sm.log_group_name
  retention_in_days = local.cloudwatch.summarization_sm.log_retention

  tags = local.combined_tags
}

# TODO: create log groups for each Lambdas
