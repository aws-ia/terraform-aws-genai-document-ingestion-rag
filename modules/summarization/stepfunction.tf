resource "aws_sfn_state_machine" "summarization_sm" {
  name     = local.statemachine.summarization.name
  role_arn = aws_iam_role.summarization_sm.arn
  definition = templatefile("${path.module}/templates/summarization_step.asl.json", {
    lambda_summarization_input_validation = aws_lambda_function.summarization_input_validation.arn
    lambda_summarization_doc_reader       = aws_lambda_function.summarization_doc_reader.arn
    lambda_summarization_generator        = aws_lambda_function.summarization_generator.arn
  })

  logging_configuration {
    level                  = local.statemachine.summarization.logging_configuration.level
    include_execution_data = local.statemachine.summarization.logging_configuration.include_execution_data
    log_destination        = "${aws_cloudwatch_log_group.summarization_sm.arn}:*"
  }

  tracing_configuration {
    enabled = true
  }

  tags = local.combined_tags
}
