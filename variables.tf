###### General variables ######
variable "stage" {
  description = "The stage for the deployment, default is '-dev'"
  default     = "-dev"
  type        = string
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

variable "container_platform" {
  description = "The platform for the container image, default is 'linux/arm64'"
  default     = "linux/arm64"
  type        = string
}

###### VPC variables ######
variable "vpc_props" {
  description = "Properties for the VPC to be deployed. Error if both this and 'deploy_vpc' are provided"
  type        = any
  default = {
    cidr_block : "10.0.0.0/20"
    az_count = 2
    subnets = {
      public = {
        netmask                   = 24
        nat_gateway_configuration = "all_azs"
      }
      private = {
        netmask                 = 24
        connect_to_public_natgw = true
      }
    }
    vpc_flow_logs = {
      log_destination_type = "cloud-watch-logs"
      retention_in_days    = 180
    }
  }
}

###### Open Search variables ######
variable "open_search_props" {
  description = "Properties for the OpenSearch configuration"
  type        = any
  default = {
    open_search_service_type = "aoss"

    domain_name    = "opensearch"
    engine_version = "OpenSearch_1.0"

    index_name = "doc-rag-search"
    secret     = "NONE"

    collection_name  = "rag-collection"
    standby_replicas = 2

    ebs_options = {
      ebs_enabled = true
      volume_type = "gp3"
      volume_size = 10
    }

    cluster_config = {
      instance_count = 4
      instance_type  = "r6g.large.search"

      dedicated_master_count   = 4
      dedicated_master_enabled = true
      dedicated_master_type    = "c6g.large.search"

      zone_awareness_config = {
        availability_zone_count = 2
      }

      zone_awareness_enabled = true
    }
  }
}

# tflint-ignore: terraform_unused_declarations
# variable "existing_vpc" {
#   description = "Existing VPC to be used. If not provided, a new one will be created"
#   type = object({
#     id: string
#   })
#   default = null
# }



# variable "observability" {
#   description = "Enable or disable observability, default is true"
#   type = bool
#   default = true
# }
# variable "merged_api_name" {
#   default = "MergedGraphqlApi"
#   type = string
# }


# Bucket variables
# tflint-ignore: terraform_unused_declarations
# variable "bucket_props" {
#   description = "Properties for the bucket, default is null"
#   default = null
# }
# # tflint-ignore: terraform_unused_declarations
# variable "existing_logging_bucket_obj" {
#   description = "Existing logging bucket to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "logging_bucket_props" {
#   description = "Properties for the logging bucket, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "log_s3_access_logs" {
#   description = "Enable or disable logging of S3 access logs, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_security_group_id" {
#   description = "Existing security group to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_bucket_interface" {
#   description = "Existing bucket interface to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_input_assets_bucket_obj" {
#   description = "Existing input assets bucket to be used. Provide 'bucket' and 'id' based on your configuration needs"
#   type = object({
#     bucket: string
#     id: string
#   })
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "bucket_inputs_assets_props" {
#   description = "Properties for the input assets bucket, default is null"
#   default = null
# }

# API variables
# tflint-ignore: terraform_unused_declarations
# variable "enable_xray" {
#   description = "Enable or disable X-Ray, default is true"
#   default = true
#   type = bool
# }

# tflint-ignore: terraform_unused_declarations
# variable "api_log_config" {
#   description = "Configuration for API logging, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "use_existing_merged_api" {
#   description = "Use existing merged API, default is false"
#   default = false
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_merged_api" {
#   description = "Existing merged API to be used. Provide 'id' and 'url' based on your configuration needs"
#   type = object({
#     id: string
#     url: string
#   })
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "existing_bus_interface" {
#   description = "Existing bus interface to be used, default is null"
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "open_search_secret" {
#   description = "Secret for OpenSearch. Provide 'arn' and 'secret_name' based on your configuration needs"
#   type = object({
#     arn: string
#     secret_name: string
#   })
#   default = null
# }

# tflint-ignore: terraform_unused_declarations
# variable "enable_operational_metric" {
#   description = "Enable or disable operational metric, default is null"
#   default = null
# }

# Required variables
# tflint-ignore: terraform_unused_declarations
# variable "existing_opensearch_domain" {
#   description = "Existing OpenSearch domain to be used. Provide 'domain_name' and 'endpoint' based on your configuration needs"
#   type = object({
#     domain_name: string
#     endpoint: string
#   })
#   default = {
#     domain_name = "test_name"
#     endpoint = "test_endpoint"
#   }
# }

# tflint-ignore: terraform_unused_declarations
# variable "open_search_index_name" {
#   description = "Name for the OpenSearch index, default is 'test_open_search_index_name'"
#   type = string
#   default = "test_open_search_index_name"
# }

# tflint-ignore: terraform_unused_declarations
# variable "cognito_user_pool_id" {
#   description = "ID for the Cognito user pool, default is 'test_cognito_user_pool_id'"
#   type = string
#   default = "test_cognito_user_pool_id"
# }

# Project variables
# variable "project_version" {
#   description = "Version of the project"
#   type = string
# }

# tflint-ignore: terraform_unused_declarations
# variable "constructor_name" {
#   description = "Name of the constructor"
#   type = string
# }

# variable "id" {
#   description = "ID for the resource"
#   type = string
# }

# variable "bucket_prefix" {
#   description = "Prefix for usage with s3 bucketnames"
#   type = string
#   default = "gen-ai"
# }
