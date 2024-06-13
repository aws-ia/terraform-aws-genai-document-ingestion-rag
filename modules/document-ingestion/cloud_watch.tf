resource "aws_cloudwatch_log_group" "ingestion_construct_log_group" {
  name = "${var.app_prefix}_ingestionConstructLogGroup"
  retention_in_days = 90
}

# Event Bus
resource "aws_cloudwatch_event_bus" "ingestion_event_bus" {
  name = "${var.app_prefix}_ingestionEventBus"
}

resource "aws_cloudwatch_event_target" "sfn_target" {
  rule      = aws_cloudwatch_event_rule.ingestion_rule.name
  target_id = "IngestionStateMachine"
  arn       = aws_sfn_state_machine.ingestion_state_machine.arn
}

# Log Group for Step Functions
resource "aws_cloudwatch_log_group" "ingestion_step_function_log_group" {
  name = "/aws/vendedlogs/states/constructs/${var.stage}"
}
