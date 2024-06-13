resource "aws_cloudwatch_event_rule" "ingestion_rule" {
  name        = "ingestionRule-${var.stage}"
  description = "Rule to trigger ingestion function"
  event_pattern = jsonencode({
    source = ["ingestion"]
  })
  event_bus_name = aws_cloudwatch_event_bus.ingestion_event_bus.name
}
