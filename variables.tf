variable "stage" {
  default = "-dev"
}

variable "observability" {
  type = bool
  default = true
}

# Optional variables
variable "deploy_vpc" {default = null}
variable "vpc_props" {
  type = object({
    name: string
    cidr_block: string
  })
  default = null
  description = "Optional An existing VPC in which to deploy the construct. Providing both this and vpcProps is an error"
}
variable "existing_vpc" {
  type = object({
    id: string
  })
  default = null
  description = "Optional existing security group allowing access to opensearch. Used by the lambda functions built by this construct. If not provided, the construct will create one."
}
variable "bucket_props" {default = null}
variable "existing_logging_bucket_obj" {default = null}
variable "logging_bucket_props" {default = null}
variable "log_s3_access_logs" {default = null}
variable "existing_security_group_id" {default = null}
variable "existing_bucket_interface" {default = null}
variable "existing_input_assets_bucket_obj" {
  type = object({
    bucket: string
    id: string
  })
  default = null
  description = <<-EOF
    This variable is used to specify configuration details. The default value must have the following structure:

    default = {
      bucket = string - bucket name
      id    = string - bucket id
    }

    Provide values for 'bucket' and 'id' based on your configuration needs.
  EOF
}
variable "bucket_inputs_assets_props" {default = null}
variable "enable_xray" {default = true}
variable "api_log_config" {default = null}
variable "use_existing_merged_api" {default = false}
variable "existing_merged_api" {
  type = object({
    id = string
    url = string
  })
  default = null
  description = <<-EOF
    This variable is used to specify configuration details. The default value must have the following structure:

    default = {
      id = string
      url = string
    }

    Provide values for 'id' and 'url' based on your configuration needs.
  EOF
}
variable "existing_bus_interface" {default = null}
variable "open_search_secret" {
  type = object({
    arn = string
    secret_name = string
  })
  default = null
}
variable "enable_operational_metric" {default = null}

#Requiered variables
variable "existing_opensearch_domain" {
  type = object({
    domain_name = string
    endpoint    = string
  })
  default = {
    domain_name = "test_name"
    endpoint    = "test_endpoint"
  }
  description = <<-EOF
    This variable is used to specify configuration details. The default value must have the following structure:

    default = {
      domain_name = null
      endpoint    = null
    }

    Provide values for 'domain_name' and 'endpoint' based on your configuration needs.
  EOF
}

variable "open_search_index_name" {
  type = string
  default = "test_open_search_index_name"
}
variable "cognito_user_pool_id" {
  type = string
  default = "test_cognito_user_pool_id"
}

variable "project_version" {}
variable "constructor_name" {}
variable "id" {}
