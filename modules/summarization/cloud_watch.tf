resource "aws_cloudwatch_log_group" "summarization_construct_log_group" {
  name = "${var.app_prefix}summarizationConstructLogGroup"
  retention_in_days = 90
}

resource "aws_flow_log" "flow_log" {
  log_destination_type = "cloud-watch-logs"
  log_destination = aws_cloudwatch_log_group.summarization_construct_log_group.arn
  iam_role_arn = aws_iam_role.summarization_construct_role.arn
  traffic_type = "ALL"
  vpc_id = var.vpc_id
}

# Event bus
resource "aws_cloudwatch_event_bus" "ingestion_event_bus" {
  name = "${var.app_prefix}_summarization_event_bus"
}

resource "aws_cloudwatch_log_group" "summarization_log_group" {
  name = "/aws/vendedlogs/states/constructs/summarization_log_group-${var.stage}"
}

resource "aws_cloudwatch_event_rule" "summary_mutation_rule" {
  name        = "${var.app_prefix}SummaryMutationRule"
  description = "Summary Mutation Rule"
  event_bus_name = aws_cloudwatch_event_bus.ingestion_event_bus.name
  depends_on = [aws_cloudwatch_event_bus.ingestion_event_bus]
  event_pattern = <<PATTERN
{
  "source": ["questionanswering"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "summary_mutation_target" {
  rule      = aws_cloudwatch_event_rule.summary_mutation_rule.name
  target_id = "${var.app_prefix}_summarisation_event_target"
  arn       = aws_sfn_state_machine.summarization_step_function.arn
  role_arn  = aws_iam_role.sfn_role.arn
  event_bus_name = aws_cloudwatch_event_bus.ingestion_event_bus.name
}
