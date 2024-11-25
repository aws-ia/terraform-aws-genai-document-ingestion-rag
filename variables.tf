###### General variables ######
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
  description = "The platform for the container image, default is 'linux/amd64'"
  default     = "linux/amd64" # "linux/arm64
  type        = string
}

variable "force_destroy" {
  description = "Set to true if you want to force delete resources created by this module"
  type        = bool
  default     = false
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