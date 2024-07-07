variable "open_search_service_type" {
  description = "Set the Opensearch mode: serverless (aoss) or standard (es)"
  default     = "aoss"
  type        = string
  validation {
    condition     = contains(["aoss", "es"], var.open_search_service_type)
    error_message = "Valid value is one of the following: aoss, es."
  }
}

variable "open_search_props" {
  description = "Properties for the OpenSearch configuration (https://github.com/terraform-aws-modules/terraform-aws-opensearch/blob/master/variables.tf)"
  type        = any
}

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

variable "force_destroy" {
  description = "Set to true if you want to force delete resources created by this module"
  type = bool
  default = false
}

# variable "subnets" {
#   type        = list(string)
#   description = "List of subnets for OpenSearch and Lambda"
# }

# variable "primary_security_group_id" {
#   type = string
# }

# variable "lambda_security_group_id" {
#   type = string
# }

# variable "bucket_prefix" {}
# variable "stage" {}
# variable "app_prefix" {}
# variable "merged_api_name" {}
