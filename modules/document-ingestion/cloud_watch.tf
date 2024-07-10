# resource "aws_cloudwatch_log_group" "ingestion" {
#   name              = local.cloudwatch.ingestion.log_group_name
#   retention_in_days = local.cloudwatch.ingestion.log_retention

#   tags = local.combined_tags
# }

# TODO: setup encryption with CME, setup resource policy
resource "aws_cloudwatch_event_bus" "ingestion" {
  name = local.cloudwatch.ingestion.event_bus_name
  tags = local.combined_tags
}

resource "aws_cloudwatch_event_rule" "ingestion" {
  name           = local.cloudwatch.ingestion.event_bus_name
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

# # Log Group for Step Functions
resource "aws_cloudwatch_log_group" "ingestion_sm" {
  name              = local.cloudwatch.ingestion_sm.log_group_name
  retention_in_days = local.cloudwatch.ingestion_sm.log_retention

  tags = local.combined_tags
}
