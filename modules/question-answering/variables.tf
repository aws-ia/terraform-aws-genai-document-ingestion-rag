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

variable "lambda_question_answering_prop" {
  description = "Properties for Lambda question answering"
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

variable "container_platform" {
  description = "The platform for the container image, default is 'linux/arm64'"
  default     = "linux/arm64"
  type        = string
}

variable "opensearch_prop" {
  description = "Properties for Opensearch cluster"
  type        = any
  default     = null
}

variable "processed_assets_bucket_prop" {
  description = "Properties for processed assets S3 bucket"
  type        = map(any)
}
