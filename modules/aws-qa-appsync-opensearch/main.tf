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

// Security Group for controlling access to resources within the VPC
resource "aws_security_group" "security_group" {
  name        = "secureGroup-${var.stage}"
  description = "Security group for ${var.stage} environment with controlled access"
  vpc_id      = aws_vpc.vpc.id
}

// Egress rule for HTTPS traffic
resource "aws_security_group_rule" "secure_group_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.10.10.0/24"]  // Specific CIDR for external services
  security_group_id = aws_security_group.security_group.id
  description       = "Allow HTTPS traffic to specific services"
}

// Ingress rule for HTTP - Restrict to necessary sources
resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]  // Adjust based on actual requirements
  security_group_id = aws_security_group.security_group.id
  description       = "Allow HTTP traffic from specific IPs"
}

// AWS OpenSearch Domain Configuration
resource "aws_opensearch_domain" "opensearch_domain" {
  domain_name    = var.domain
  engine_version = "OpenSearch_1.0"

  cluster_config {
    instance_type          = "m4.large.search"
    instance_count         = 2  // Increase count based on your usage
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 3  // Ensure high availability with 3 AZs
    }
    dedicated_master_enabled = true
    dedicated_master_type    = "m4.large.search"
    dedicated_master_count   = 3
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.customer_managed_kms_key.arn  // Ensure this key is correctly defined in your Terraform
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"  // Use an updated TLS policy
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_audit_log.arn
    log_type                 = "AUDIT_LOGS"

    audit_log {
      enabled = true
    }
  }

  vpc_options {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.security_group.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {"AWS": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]},
      Action    = "es:*",
      Resource  = "arn:aws:es:${var.region}:${var.account_id}:domain/${var.domain}/*"
    }]
  })

  tags = {
    Domain = "TestDomain"
  }

  depends_on = [aws_iam_service_linked_role.example]
}

resource "aws_cloudwatch_log_group" "opensearch_audit_log" {
  name              = "/aws/opensearch/${var.domain}/audit-log"
  retention_in_days = 365
kms_key_id        = aws_kms_key.customer_managed_kms_key.arn

}

// AWS Lambda permissions for CloudWatch event triggers
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering_function.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.question_answering_rule.arn
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

// Default Security Group settings for the VPC
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = []
    description = "Deny all inbound traffic"
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = []
    description = "Deny all outbound traffic"
  }
}
