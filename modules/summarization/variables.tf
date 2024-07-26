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
  description = "Properties for Lambda summarization input validation"
  type        = any
}

variable "lambda_summarization_doc_reader_prop" {
  description = "Properties for Lambda summarization doc reader"
  type        = any
}

variable "lambda_summarization_generator_prop" {
  description = "Properties for Lambda summarization generator"
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

variable "input_assets_bucket_prop" {
  description = "Properties for input assets S3 bucket"
  type        = map(any)
}

variable "processed_assets_bucket_prop" {
  description = "Properties for processed assets S3 bucket"
  type        = map(any)
}

variable "container_platform" {
  description = "The platform for the container image, default is 'linux/arm64'"
  default     = "linux/arm64"
  type        = string
}

variable "is_file_transformation_required" {
  description = "Whether file transformation is required or not"
  type        = bool
  default     = true
}

variable "summary_chain_type" {
  description = "Summarization chain type (default 'stuff')"
  type        = string
  default     = "stuff"
}

variable "cloudwatch_log_group_retention" {
  description = "Lambda CloudWatch log group retention period"
  type        = string
  default     = "365"
  validation {
    condition     = contains(["1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653", "0"], var.cloudwatch_log_group_retention)
    error_message = "Valid values for var: cloudwatch_log_group_retention are (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0)."
  }
}

variable "lambda_reserved_concurrency" {
  description = "Maximum Lambda reserved concurrency, make sure your AWS quota is sufficient"
  type        = number
  default     = 10
}