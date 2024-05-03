resource "aws_cloudwatch_log_group" "qa_construct_log_group" {
  name = "qaConstructLogGroup"
}

resource "aws_flow_log" "flow_log" {
  traffic_type = "ALL"
  log_destination = aws_cloudwatch_log_group.qa_construct_log_group.arn
  iam_role_arn = aws_iam_role.qa_construct_role.arn
  vpc_id = local.vpc_id
}

resource "aws_cloudwatch_event_bus" "question_answering_event_bus" {
  name         = "questionAnsweringEventBus${var.stage}"
}

resource "aws_cloudwatch_event_rule" "question_answering_rule" {
  name        = "QuestionAnsweringRule"
  description = "Rule to trigger question answering function"
  event_bus_name = aws_cloudwatch_event_bus.question_answering_event_bus.name

  event_pattern = <<PATTERN
{
  "source": ["questionanswering"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "question_answering_target" {
  rule        = aws_cloudwatch_event_rule.question_answering_rule.name
  target_id   = "QuestionAnsweringFunctionTarget"
  arn         = aws_lambda_function.question_answering_function.arn
}
