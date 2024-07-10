resource "aws_sfn_state_machine" "ingestion_sm" {
  name     = local.statemachine.ingestion.name
  role_arn = aws_iam_role.ingestion_sm.arn
  definition = jsonencode({
    StartAt = "Validate Ingestion Input"
    States = {
      "Validate Ingestion Input" = {
        Type     = "Task"
        Resource = aws_lambda_function.ingestion_input_validation.arn
        Next     = "Is Valid Ingestion Parameters?"
      }
      "Is Valid Ingestion Parameters?" = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.isValid"
            BooleanEquals = false
            Next          = "Job Failed"
          }
        ]
        Default = "Map State"
      }
      "Map State" = {
        Type      = "Map"
        ItemsPath = "$.files"
        Iterator = {
          StartAt = "Download and transform document to raw text"
          States = {
            "Download and transform document to raw text" = {
              Type     = "Task"
              Resource = aws_lambda_function.file_transformer.arn
              End      = true
            }
          }
        }
        End = true
      }
      "Job Failed" = {
        Type  = "Fail"
        Cause = "Validation job failed"
        Error = "DescribeJob returned FAILED"
      }
    }
  })
  logging_configuration {
    level                  = local.statemachine.ingestion.logging_configuration.level
    include_execution_data = local.statemachine.ingestion.logging_configuration.include_execution_data
    log_destination        = "${aws_cloudwatch_log_group.ingestion_sm.arn}:*"
  }

  tags = local.combined_tags
}
