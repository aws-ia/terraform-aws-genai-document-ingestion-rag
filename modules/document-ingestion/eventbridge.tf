resource "aws_cloudwatch_event_rule" "ingestion_rule" {
  name           = "${var.app_prefix}IngestionRule"
  description    = "Rule to trigger ingestion state machine"
  event_bus_name = aws_cloudwatch_event_bus.ingestion_event_bus.name

  event_pattern = <<PATTERN
{
  "source": ["ingestion"]
}
PATTERN
}
