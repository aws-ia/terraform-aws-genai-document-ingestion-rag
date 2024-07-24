# TODO: setup resource policy, DLQ
resource "awscc_events_event_bus" "question_answering" {
  name = "${local.cloudwatch.question_answering_api.event_bus_name}"
  kms_key_identifier = aws_kms_alias.question_answering.arn  
  tags = [
    for k, v in local.combined_tags :
    {
      key : k,
      value : v
    }
  ]
}

# TODO: move to templatefile
resource "aws_cloudwatch_event_rule" "question_answering" {
  name           = local.cloudwatch.question_answering_api.event_bus_name
  description    = "Rule to trigger question answering function"
  event_bus_name = awscc_events_event_bus.question_answering.name

  event_pattern = <<PATTERN
    {
      "source": ["questionanswering"],
      "detail-type": ["genAIdemo"]
    }
  PATTERN
}

resource "aws_cloudwatch_event_target" "question_answering" {
  rule           = aws_cloudwatch_event_rule.question_answering.name
  target_id      = local.cloudwatch.question_answering_sm.event_bridge_target_id
  arn            = aws_lambda_function.question_answering.arn
  event_bus_name = awscc_events_event_bus.question_answering.name
}