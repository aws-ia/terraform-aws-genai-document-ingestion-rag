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

// Security group creation without embedded egress rules
resource "aws_security_group" "security_group" {
  name        = "secureGroup${var.stage}"
  description = "Security group for ${var.stage} environment with controlled access"
  vpc_id      = aws_vpc.vpc.id
}

// Separate egress rule for HTTPS traffic
resource "aws_security_group_rule" "secure_group_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.10.10.0/24"] // Adjust to the necessary external service CIDR
  security_group_id = aws_security_group.security_group.id
  description       = "Allow necessary outbound traffic to specific services on HTTPS"
}

// Additional egress rules for other specific services
resource "aws_security_group_rule" "secure_group_egress_other" {
  type              = "egress"
  from_port         = 1024
  to_port           = 2048
  protocol          = "tcp"
  cidr_blocks       = ["10.20.30.0/24"] // Adjust as necessary for other services
  security_group_id = aws_security_group.security_group.id
  description       = "Allow necessary outbound traffic to other specific services"
}

// Example ingress rule for HTTP (restrict to necessary sources)
resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"] // Adjust to the actual IPs needing access
  security_group_id = aws_security_group.security_group.id
  description       = "Allow HTTP traffic from specific IPs"
}

// Example ingress rule for HTTPS (consider security implications of wide access)
resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.10.10.0/24"] // Adjust or remove if external access is not necessary
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


resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Deny all inbound traffic"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Deny all outbound traffic"
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
