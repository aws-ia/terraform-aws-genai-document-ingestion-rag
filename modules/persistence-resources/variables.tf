variable "open_search-service_type" {
  default = "aoss"
  type = string
}

variable "open_search_domain_name" {
  default = "opensearch"
}

variable "open_search_engine_version" {
  default = "OpenSearch_1.0"
}

variable "open_search_props" {
  description = "Properties for the OpenSearch configuration"
  default     = {
    master_nodes = 3
    master_node_instance_type = "r5.large.elasticsearch"
    data_nodes = 3
    data_node_instance_type = "r5.large.elasticsearch"
    availability_zone_count = 2
    volume_size = 10
    collection_name = "example-collection"
    standby_replicas = 2
    open_search_vpc_endpoint_id = ""
  }
}

variable "isolated_subnet_id" {
  type = string
}
variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "primary_security_group_id" {
  type = string
}

variable "lambda_security_group_id" {
  type = string
}

variable "bucket_prefix" {}
variable "stage" {}
variable "app_prefix" {}
variable "merged_api_name" {}
variable "client_url" { type = string }
