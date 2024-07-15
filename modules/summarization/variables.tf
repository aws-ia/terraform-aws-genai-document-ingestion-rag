variable "solution_prefix" {
  description = "Prefix to be included in all resources deployed by this solution"
  type        = string
  default     = "aws-ia"
}

variable "tags" {
  description = "Map of tags to apply to resources deployed by this solution."
  type        = map(any)
  default     = null
}

variable "cognito_user_pool_id" {
  description = "Cognito user pool for AppSync"
  type        = string
}

variable "ecr_repository_id" {
  description = "ECR Repo Name"
  type        = string
}

variable "lambda_summarization_input_validation_prop" {
  description = "Properties for Lambda document ingestion"
  type        = any
}

variable "merged_api_arn" {
  description = "AppSync Merged API ARN"
  type        = string
  default     = ""
}

variable "merged_api_url" {
  description = "AppSync Merged API URL"
  type        = string
  default     = ""
}

# variable "vpc_id" {
#   description = "The ID of the VPC"
#   type        = string
# }
# variable "app_prefix" {}

# variable "input_assets_bucket_name" {}
# variable "input_assets_bucket_arn" {}
# variable "processed_assets_bucket_name" {}
# variable "processed_assets_bucket_arn" {}
# variable "existing_merged_api_id" {
#   description = "The existing merged API ID, if any"
#   type        = string
#   default     = ""
# }
# variable "ecr_repository_url" {
#   type = string
# }

# variable "security_groups_ids" { type = list(string) }
# variable "subnet_ids" { type = list(string) }
# variable "is_file_transformation_required" {
#   type    = bool
#   default = true
# }
# variable "summary_chain_type" {
#   type    = string
#   default = ""
# }
# variable "cognito_user_pool_id" { type = string }
# variable "stage" { type = string }
# variable "access_logs_bucket_name" { type = string }
# variable "access_logs_bucket_arn" { type = string }

# variable "merged_api_url" {
#   type    = string
#   default = ""
# }
