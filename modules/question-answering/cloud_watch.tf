# TODO: setup encryption with CME, setup resource policy
resource "aws_cloudwatch_event_bus" "question_answering" {
  name = local.cloudwatch.question_answering.event_bus_name
  tags = local.combined_tags
}

# TODO: move to templatefile
resource "aws_cloudwatch_event_rule" "question_answering" {
  name           = local.cloudwatch.question_answering.event_bus_name
  description    = "Rule to trigger question answering function"
  event_bus_name = aws_cloudwatch_event_bus.question_answering.name

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
  event_bus_name = aws_cloudwatch_event_bus.question_answering.name
}