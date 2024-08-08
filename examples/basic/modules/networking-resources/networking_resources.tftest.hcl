variables {
  solution_prefix = "test-prefix"
  vpc_props = {
    cidr_block    = "10.0.0.0/16"
    az_count      = 2
    subnets = {
      private = { netmask = 24 }
      public  = { netmask = 24 }
    }
    vpc_flow_logs = {
      log_destination_type = "cloud-watch-logs"
      retention_in_days    = 7
    }
  }
  tags = {
    Environment = "Test"
    Project     = "Networking"
  }
}

run "verify_networking_resources_module" {
  module {
    source = "../../../../modules/networking-resources"
  }
  command = plan

  assert {
    condition     = module.vpc.vpc_attributes.cidr_block == var.vpc_props.cidr_block
    error_message = "VPC CIDR block is incorrect"
  }

  assert {
    condition     = length(module.vpc.private_subnet_attributes_by_az) == var.vpc_props.az_count
    error_message = "Number of private subnets does not match az_count"
  }

  assert {
    condition     = length(module.vpc.public_subnet_attributes_by_az) == var.vpc_props.az_count
    error_message = "Number of public subnets does not match az_count"
  }

  assert {
    condition     = aws_security_group.lambda.name == "${var.solution_prefix}-lambda-sg"
    error_message = "Lambda security group name is incorrect"
  }

  assert {
    condition     = aws_security_group.primary.name == "${var.solution_prefix}-primary-sg"
    error_message = "Primary security group name is incorrect"
  }

  assert {
    condition     = aws_opensearchserverless_vpc_endpoint.opensearch.name == "${var.solution_prefix}-opensearch"
    error_message = "OpenSearch VPC endpoint name is incorrect"
  }

  assert {
    condition     = aws_vpc_endpoint.s3.vpc_endpoint_type == "Gateway"
    error_message = "S3 VPC endpoint type is not Gateway"
  }

  assert {
    condition     = module.vpc.vpc_attributes.tags["Environment"] == var.tags["Environment"]
    error_message = "VPC Environment tag is incorrect"
  }

  assert {
    condition     = module.vpc.vpc_attributes.tags["Project"] == var.tags["Project"]
    error_message = "VPC Project tag is incorrect"
  }

  assert {
    condition     = module.vpc.vpc_attributes.tags["Submodule"] == "networking-resources"
    error_message = "VPC Submodule tag is incorrect"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.to_internet.cidr_ipv4 == "0.0.0.0/0"
    error_message = "Lambda security group egress rule CIDR is incorrect"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.https_within_sg.from_port == 443
    error_message = "Lambda security group ingress rule port is incorrect"
  }
}