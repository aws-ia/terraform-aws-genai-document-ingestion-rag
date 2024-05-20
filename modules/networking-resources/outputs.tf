output "private_subnet_ids" {
  value = [aws_subnet.private.id]
}

output "opensearch_vpc_endpoint" {
  value = aws_vpc_endpoint.opensearch.arn
}

output "security_group" {
  value = aws_security_group.lambda_sg
}

output "vpc_arn" {
  value = aws_vpc.main_vpc.arn
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public
}

output "private_subnet_id" {
  value = aws_subnet.private
}

output "isolated_subnet_id" {
  value = aws_subnet.isolated
}

output "primary_security_group_id" {
  value = aws_security_group.security_group_primary
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg
}