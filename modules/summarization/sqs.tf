# TODO: set KMS key
resource "aws_sqs_queue" "summarization_sm_dlq" {
  name                      = local.statemachine.summarization.name
  message_retention_seconds = 604800 # 7 days

  tags = local.combined_tags
}

resource "aws_sqs_queue_policy" "summarization_sm_dlq" {
  queue_url = aws_sqs_queue.summarization_sm_dlq.id
  policy    = data.aws_iam_policy_document.summarization_sm_dlq.json
}