resource "aws_cloudwatch_event_bus" "summarization" {
  name = local.cloudwatch.summarization.event_bus_name
  tags = local.combined_tags
}

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
}

# TODO: add KMS key
resource "aws_cloudwatch_log_group" "summarization_sm" {
  name              = local.cloudwatch.summarization_sm.log_group_name
  retention_in_days = local.cloudwatch.summarization_sm.log_retention

  tags = local.combined_tags
}

# TODO: create log groups for each Lambdas

# resource "aws_cloudwatch_log_group" "summarization_construct_log_group" {
#   name              = "${var.app_prefix}summarizationConstructLogGroup"
#   retention_in_days = 90
# }

# resource "aws_flow_log" "flow_log" {
#   log_destination_type = "cloud-watch-logs"
#   log_destination      = aws_cloudwatch_log_group.summarization_construct_log_group.arn
#   iam_role_arn         = aws_iam_role.summarization_construct_role.arn
#   traffic_type         = "ALL"
#   vpc_id               = var.vpc_id
# }

