output "private_subnet_ids" {
  value = [aws_subnet.private.id]
}

output "opensearch_vpc_endpoint" {
  value = aws_opensearchserverless_vpc_endpoint.opensearch.id
}

output "vpc_arn" {
  value = aws_vpc.main_vpc.arn
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "isolated_subnet_id" {
  value = aws_subnet.isolated.id
}

output "primary_security_group_id" {
  value = aws_security_group.security_group_primary.id
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg.id
}