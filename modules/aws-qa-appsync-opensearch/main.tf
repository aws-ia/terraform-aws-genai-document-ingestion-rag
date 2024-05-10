// Trigger for error handling
resource "null_resource" "error_trigger" {
  count = length(local.error_messages) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo '${join("\n", local.error_messages)}' && exit 1"
  }
}

// VPC Configuration
resource "aws_vpc" "vpc" {
  cidr_block = local.existing_vpc_bool ? null : var.vpc_props.cidr_block
}

// Security group with restricted egress and ingress
resource "aws_security_group" "security_group" {
  name        = "secureGroup${var.stage}"
  description = "Security group for ${var.stage} environment with controlled access"
  vpc_id      = aws_vpc.vpc.id

  // Define egress to only specific required services or IPs
  egress {
    description = "Allow necessary outbound traffic to specific services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.10.10.0/24"] // Example CIDR for required external services; adjust as necessary
  }
}

resource "aws_security_group_rule" "secure_group_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.10.10.0/24"] // Adjust the CIDR to match required external services
  security_group_id = aws_security_group.security_group.id
  description       = "Allow necessary outbound traffic to specific services on HTTPS"
}

// Additional egress rules can be added similarly
resource "aws_security_group_rule" "secure_group_egress_other" {
  type              = "egress"
  from_port         = 1024
  to_port           = 2048
  protocol          = "tcp"
  cidr_blocks       = ["10.20.30.0/24"] // Example CIDR for other services
  security_group_id = aws_security_group.security_group.id
  description       = "Allow necessary outbound traffic to other specific services"
}

// Restrict HTTP access to known IPs if HTTP is necessary, otherwise remove or switch to HTTPS
resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"] // Example CIDR, replace with actual IPs needing access
  security_group_id = aws_security_group.security_group.id
  description       = "Allow HTTP traffic from specific IPs"
}

// HTTPS access; consider whether this should be open to the entire internet
resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.10.10.0/24"] // Replace with actual IPs or remove if no external access is necessary
  security_group_id = aws_security_group.security_group.id
  description       = "Allow HTTPS traffic from specific trusted sources"
}

// Private subnet configuration
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = aws_vpc.vpc.cidr_block
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet-${var.stage}"
  }
}

// Lambda permission for CloudWatch event triggers
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering_function.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.question_answering_rule.arn
}
