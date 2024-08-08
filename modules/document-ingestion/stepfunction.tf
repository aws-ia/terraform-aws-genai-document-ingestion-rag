resource "aws_sfn_state_machine" "ingestion_sm" {
  name     = local.statemachine.ingestion.name
  role_arn = aws_iam_role.ingestion_sm.arn
  definition = templatefile("${path.module}/templates/ingestion_step.asl.json", {
    lambda_ingestion_input_validation = aws_lambda_function.ingestion_input_validation.arn
    lambda_file_transformer           = aws_lambda_function.file_transformer.arn
    lambda_embeddings_job             = aws_lambda_function.embeddings_job.arn
  })

  logging_configuration {
    level                  = local.statemachine.ingestion.logging_configuration.level
    include_execution_data = local.statemachine.ingestion.logging_configuration.include_execution_data
    log_destination        = "${aws_cloudwatch_log_group.ingestion_sm.arn}:*"
  }

  tracing_configuration {
    enabled = true
  }

  tags = local.combined_tags
}
