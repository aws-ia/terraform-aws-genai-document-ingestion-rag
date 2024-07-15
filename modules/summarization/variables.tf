variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "app_prefix" {}

variable "input_assets_bucket_name" {}
variable "input_assets_bucket_arn" {}
variable "processed_assets_bucket_name" {}
variable "processed_assets_bucket_arn" {}
variable "existing_merged_api_id" {
  description = "The existing merged API ID, if any"
  type        = string
  default     = ""
}
variable "ecr_repository_url" {
  type = string
}

variable "private_subnet_id" {type = string}
variable "security_group_id" {type = string}
variable "is_file_transformation_required" {
  type = bool
  default = true
}
variable "summary_chain_type" {
  type = string
  default = ""
}
variable "cognito_user_pool_id" {type = string}
variable "stage" {type = string}
variable "access_logs_bucket_name" {type = string}
variable "access_logs_bucket_arn" {type = string}

variable "merged_api_url" {
  type = string
  default = ""
}
