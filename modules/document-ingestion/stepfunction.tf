resource "aws_sfn_state_machine" "ingestion_state_machine" {
  name     = "IngestionStateMachine-${var.stage}"
  role_arn = aws_iam_role.sfn_role.arn
  definition = jsonencode({
    StartAt = "Validate Ingestion Input"
    States = {
      "Validate Ingestion Input" = {
        Type     = "Task"
        Resource = aws_lambda_function.input_validation_lambda.arn
        Next     = "Is Valid Ingestion Parameters?"
      }
      "Is Valid Ingestion Parameters?" = {
        Type = "Choice"
        Choices = [
          {
            Variable  = "$.validation_result.Payload.isValid"
            BooleanEquals = false
            Next      = "Job Failed"
          }
        ]
        Default = "Map State"
      }
      "Map State" = {
        Type     = "Map"
        Iterator = {
          StartAt = "Download and transform document to raw text"
          States = {
            "Download and transform document to raw text" = {
              Type     = "Task"
              Resource = aws_lambda_function.file_transformer_lambda.arn
              End      = true
            }
          }
        }
      }
      "Job Failed" = {
        Type = "Fail"
        Cause = "Validation job failed"
        Error = "DescribeJob returned FAILED"
      }
    }
  })
  logging_configuration {
    level = "ALL"
    include_execution_data = true
    log_destination = aws_cloudwatch_log_group.ingestion_step_function_log_group.arn
  }
}