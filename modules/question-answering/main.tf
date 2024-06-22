# resource "aws_cloudwatch_log_group" "qa_construct_log_group" {
#   name = "${var.app_prefix}-qaConstructLogGroup"
# }
#
# resource "aws_flow_log" "flow_log" {
#   log_destination_type = "cloud-watch-logs"
#   log_destination = aws_cloudwatch_log_group.qa_construct_log_group.arn
#   iam_role_arn = aws_iam_role.qa_construct_role.arn
#   traffic_type = "ALL"
#   vpc_id = var.vpc_id
# }
#
# resource "aws_cloudwatch_event_bus" "question_answering_event_bus" {
#   name = "${var.app_prefix}questionAnsweringEventBus"
# }
#
# resource "aws_cloudwatch_event_rule" "question_answering_rule" {
#   name           = "${var.app_prefix}QuestionAnsweringRule"
#   description    = "Rule to trigger question answering function"
#   event_bus_name = aws_cloudwatch_event_bus.question_answering_event_bus.name
#   depends_on = [aws_cloudwatch_event_bus.question_answering_event_bus]
#
#   event_pattern = <<PATTERN
# {
#   "source": ["questionanswering"]
# }
# PATTERN
# }
#
# resource "aws_cloudwatch_event_target" "question_answering_target" {
#   rule      = aws_cloudwatch_event_rule.question_answering_rule.name
#   target_id = "${var.app_prefix}_question_answering_event_target"
#   arn       = aws_lambda_function.question_answering_function.arn
#
#   depends_on = [
#     null_resource.build_and_push_image,
#     aws_lambda_function.question_answering_function,
#     aws_cloudwatch_event_rule.question_answering_rule
#   ]
# }
#
# resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.question_answering_function.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.question_answering_rule.arn
#
#   depends_on = [aws_cloudwatch_event_rule.question_answering_rule]
# }

resource "aws_cloudwatch_log_group" "qa_construct_log_group" {
  name = "${var.app_prefix}-qaConstructLogGroup"
}

resource "aws_flow_log" "flow_log" {
  log_destination_type = "cloud-watch-logs"
  log_destination = aws_cloudwatch_log_group.qa_construct_log_group.arn
  iam_role_arn = aws_iam_role.qa_construct_role.arn
  traffic_type = "ALL"
  vpc_id = var.vpc_id
}

resource "aws_cloudwatch_event_bus" "question_answering_event_bus" {
  name = "${var.app_prefix}questionAnsweringEventBus"
}

resource "aws_cloudwatch_event_rule" "question_answering_rule" {
  name           = "${var.app_prefix}QuestionAnsweringRule"
  description    = "Rule to trigger question answering function"
  event_bus_name = aws_cloudwatch_event_bus.question_answering_event_bus.name
  depends_on = [aws_cloudwatch_event_bus.question_answering_event_bus]

  event_pattern = <<PATTERN
{
  "source": ["questionanswering"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "question_answering_target" {
  rule      = aws_cloudwatch_event_rule.question_answering_rule.name
  target_id = "${var.app_prefix}_question_answering_event_target"
  arn       = aws_lambda_function.question_answering_function.arn
  event_bus_name = aws_cloudwatch_event_bus.question_answering_event_bus.name

  depends_on = [
    null_resource.build_and_push_image,
    aws_lambda_function.question_answering_function,
    aws_cloudwatch_event_rule.question_answering_rule
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.question_answering_rule.arn

  depends_on = [aws_cloudwatch_event_rule.question_answering_rule]
}
