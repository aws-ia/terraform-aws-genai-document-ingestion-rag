output "vpc_attributes" {
  description = "All VPC module attributes"
  value       = module.networking_resources.vpc_attributes
}