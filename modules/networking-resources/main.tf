module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.4.2"

  name          = var.solution_prefix
  cidr_block    = var.vpc_props.cidr_block
  az_count      = var.vpc_props.az_count
  subnets       = var.vpc_props.subnets
  vpc_flow_logs = var.vpc_props.vpc_flow_logs

  tags = local.combined_tags
  #checkov:skip=CKV_TF_1:skip module source commit hash
}

resource "aws_security_group" "lambda" {
  name        = "${var.solution_prefix}-lambda-sg"
  description = "Security group for ${var.solution_prefix} Lambda"
  vpc_id      = module.vpc.vpc_attributes.id
  tags        = local.combined_tags
  #checkov:skip=CKV2_AWS_5:security group is attached to lambda on separate module
}

resource "aws_vpc_security_group_egress_rule" "to_internet" {
  description       = "Allow all outbound traffic"
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.lambda.id
}

resource "aws_vpc_security_group_ingress_rule" "https_within_sg" {
  description       = "Allow inbound traffic from VPC subnets"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.lambda.id
}

resource "aws_security_group" "primary" {
  name        = "${var.solution_prefix}-primary-sg"
  description = "Primary security group for ${var.solution_prefix} environment with controlled access"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = local.combined_tags
  #checkov:skip=CKV2_AWS_5:security group is attached to lambda on separate module
}

resource "aws_opensearchserverless_vpc_endpoint" "opensearch" {
  name       = "${var.solution_prefix}-opensearch"
  subnet_ids = [for _, value in module.vpc.private_subnet_attributes_by_az : value.id]
  vpc_id     = module.vpc.vpc_attributes.id
  security_group_ids = [aws_security_group.lambda.id]
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_attributes.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [for _, value in module.vpc.rt_attributes_by_type_by_az.private : value.id]

  tags = local.combined_tags
}