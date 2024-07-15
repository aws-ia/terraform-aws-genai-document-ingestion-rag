# General variables
variable "stage" {
  description = "The stage for the deployment, default is '-dev'"
  default = "-dev"
  type = string
}

# tflint-ignore: terraform_unused_declarations
variable "observability" {
  description = "Enable or disable observability, default is true"
  type = bool
  default = true
}
variable "merged_api_name" {
  default = "MergedGraphqlApi"
  type = string
}

variable "bucket_prefix" {
  description = "Prefix for usage with s3 bucketnames"
  type = string
  default = "gen-ai"
}

variable "client_url" {
  type = string
  default = "http://localhost:8501/"
}
