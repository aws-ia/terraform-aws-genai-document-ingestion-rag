output "vpc_attributes" {
  description = "All VPC module attributes"
  value       = module.vpc.vpc_attributes
}

output "private_subnet_attributes" {
  description = "Public subnet attributes"
  value       = module.vpc.private_subnet_attributes_by_az
}

output "lambda_sg" {
  description = "Lambda SG"
  value       = aws_security_group.lambda.id
}

output "primary_sg" {
  description = "Primary SG"
  value       = aws_security_group.primary.id
}