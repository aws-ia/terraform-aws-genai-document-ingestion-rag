variable "vpc_props" {
  description = "Properties for the VPC to be deployed. (https://github.com/aws-ia/terraform-aws-vpc/blob/main/variables.tf)"
  type        = any
}

variable "solution_prefix" {
  description = "Prefix to be included in all resources deployed by this solution"
  type        = string
  default     = "aws-ia"
}

variable "tags" {
  description = "Map of tags to apply to resources deployed by this solution."
  type        = any
  default     = null
}