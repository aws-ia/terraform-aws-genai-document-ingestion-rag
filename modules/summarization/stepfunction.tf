resource "aws_sfn_state_machine" "summarization_step_function" {
  name     = "${var.app_prefix}summarizationStepFunction"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    StartAt = "ValidateInputTask",
    States = {
      ValidateInputTask = {
        Type       = "Task",
        Resource   = aws_lambda_function.input_validation_lambda.arn,
#        ResultPath = "$.validation_result",
        Next       = "ValidateInputChoice"
      },
      ValidateInputChoice = {
        Type       = "Choice",
#        OutputPath = "$.validation_result.Payload.files",
        Choices = [
          {
            Variable  = "$.validation_result.Payload.isValid",
            BooleanEquals = false,
            Next      = "JobFailed"
          }
        ],
        Default = "RunFilesInParallel"
      },
      RunFilesInParallel = {
        Type       = "Map",
        ItemsPath  = "$.files",
        MaxConcurrency = 100,
        Iterator = {
          StartAt = "ReadDocumentTask",
          States = {
            ReadDocumentTask = {
              Type       = "Task",
              Resource   = aws_lambda_function.document_reader_lambda.arn,
              ResultPath = "$.document_result",
              Next       = "FileStatusForSummarization"
            },
            FileStatusForSummarization = {
              Type       = "Choice",
#              OutputPath = "$.document_result.Payload",
              Choices = [
                {
                  Variable  = "$.document_result.Payload.status",
                  StringEquals = "Error",
                  Next      = "IteratorJobFailed"
                }
              ],
              Default = "GenerateSummaryTask"
            },
            GenerateSummaryTask = {
              Type       = "Task",
              Resource   = aws_lambda_function.generate_summary_lambda.arn,
              ResultPath = "$.summary_result",
              End        = true
            },
            IteratorJobFailed = {
              Type       = "Fail",
              Error      = "JobFailed",
              Cause      = "AWS summary Job failed"
            }
          }
        },
        End = true
      },
      JobFailed = {
        Type       = "Fail",
        Error      = "JobFailed",
        Cause      = "AWS summary Job failed"
      },
    }
  })

  logging_configuration {
    level = "ALL"
    include_execution_data = true
    log_destination = "${aws_cloudwatch_log_group.summarization_log_group.arn}:*"
  }
}
