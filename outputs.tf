output "vpc" {
  value = module.networking_resources.private_subnet_attributes_by_az
}

output "sg" {
  value = module.networking_resources.lambda_sg
}