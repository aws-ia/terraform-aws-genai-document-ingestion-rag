resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.ingestion_construct_log_group.arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.ingestion_construct_role.arn
  vpc_id               = aws_vpc.this.id
}

