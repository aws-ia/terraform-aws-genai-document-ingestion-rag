resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
    tags = {
    Name = "Application VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 0)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "PublicSubnet-${var.stage}"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 1)  # Adjust the third argument to avoid overlapping with other subnets
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "PrivateSubnet-${var.stage}"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_subnet" "isolated" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "IsolatedSubnet-${var.stage}"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "MainNATGateway-${var.stage}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name = "VPCFlowLogs"
}

resource "aws_iam_role" "flow_logs" {
  name = "VPCFlowLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main_vpc.id
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambdaSecurityGroup"
  description = "Security group for lambda"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }
}

resource "aws_security_group" "security_group_primary" {
  name        = "secureGroup-${var.stage}"
  description = "Security group for ${var.stage} environment with controlled access"
  vpc_id      = aws_vpc.main_vpc.id
}

# resource "aws_vpc_endpoint" "opensearch" {
#   vpc_id            = aws_vpc.main_vpc.id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.es"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [aws_subnet.isolated.id, aws_subnet.private.id, aws_subnet.public.id]
#   security_group_ids = [aws_security_group.lambda_sg.id]
# }
resource "aws_opensearchserverless_vpc_endpoint" "opensearch" {
  name       = "opensearch-vpc-endpoint-${var.stage}"
  subnet_ids = [aws_subnet.isolated.id, aws_subnet.private.id, aws_subnet.public.id]
  vpc_id     = aws_vpc.main_vpc.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_vpc.main_vpc.default_route_table_id]
}