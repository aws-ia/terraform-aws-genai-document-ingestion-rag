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

variable "lambda_ingestion_input_validation_prop" {
  description = "Properties for Lambda document ingestion"
  type        = map(any)
}

variable "lambda_file_transformer_prop" {
  description = "Properties for Lambda file transformer"
  type        = map(any)
}

variable "lambda_embeddings_job_prop" {
  description = "Properties for Lambda embeddings job"
  type        = map(any)
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

variable "opensearch_prop" {
  description = "Properties for Opensearch cluster"
  type        = any
  default     = null
}


# TODO: what is the use of these variables?
# variable "security_groups_ids" {type = list(string)}
# variable "subnet_ids" {type = list(string)}
# variable "ecr_repository_url" {type = string}