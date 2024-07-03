resource "aws_cloudwatch_log_group" "ingestion_construct_log_group" {
  name = "${var.app_prefix}_ingestionConstructLogGroup"
  retention_in_days = 90
}

# Event Bus
resource "aws_cloudwatch_event_bus" "ingestion_event_bus" {
  name = "${var.app_prefix}_ingestionEventBus"
}

resource "aws_cloudwatch_event_rule" "ingestion_rule" {
  name           = "${var.app_prefix}IngestionRule"
  description    = "Rule to trigger ingestion state machine"
  event_bus_name = aws_cloudwatch_event_bus.ingestion_event_bus.name

  event_pattern = <<PATTERN
    {
      "source": ["ingestion"],
      "detailType": ["genAIdemo"]
    }
  PATTERN
}

resource "aws_cloudwatch_event_target" "sfn_target" {
  rule      = aws_cloudwatch_event_rule.ingestion_rule.name
  target_id = "IngestionStateMachine"
  arn       = aws_sfn_state_machine.ingestion_state_machine.arn
  role_arn  = aws_iam_role.eventbridge_sfn_role.arn
  event_bus_name = aws_cloudwatch_event_bus.ingestion_event_bus.name

  depends_on = [
    aws_cloudwatch_event_rule.ingestion_rule,
    aws_sfn_state_machine.ingestion_state_machine,
    null_resource.build_and_push_embeddings_job_lambda_image,
    null_resource.build_and_push_input_validation_lambda_image,
    null_resource.build_and_push_file_transformer_lambda_image,
    aws_lambda_function.embeddings_job_lambda,
    aws_lambda_function.file_transformer_lambda,
    aws_lambda_function.input_validation_lambda
  ]
}

# Log Group for Step Functions
resource "aws_cloudwatch_log_group" "ingestion_step_function_log_group" {
  name = "/aws/vendedlogs/states/constructs/${var.stage}"
}
