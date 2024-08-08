<!-- BEGIN_TF_DOCS -->
# Terraform Module Project

:no\_entry\_sign: Do not edit this readme.md file. To learn how to change this content and work with this repository, refer to CONTRIBUTING.md

## Readme Content

This file will contain any instructional information about this module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.8.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.78.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | >=3.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.8.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.78.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_document_ingestion"></a> [document\_ingestion](#module\_document\_ingestion) | ./modules/document-ingestion | n/a |
| <a name="module_networking_resources"></a> [networking\_resources](#module\_networking\_resources) | ./modules/networking-resources | n/a |
| <a name="module_persistence_resources"></a> [persistence\_resources](#module\_persistence\_resources) | ./modules/persistence-resources | n/a |
| <a name="module_question_answering"></a> [question\_answering](#module\_question\_answering) | ./modules/question-answering | n/a |
| <a name="module_summarization"></a> [summarization](#module\_summarization) | ./modules/summarization | n/a |

## Resources

| Name | Type |
|------|------|
| [awscc_appsync_source_api_association.document_ingestion_association](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/appsync_source_api_association) | resource |
| [awscc_appsync_source_api_association.question_answering_association](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/appsync_source_api_association) | resource |
| [awscc_appsync_source_api_association.summarization_association](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/appsync_source_api_association) | resource |
| [random_string.solution_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_platform"></a> [container\_platform](#input\_container\_platform) | The platform for the container image, default is 'linux/arm64' | `string` | `"linux/arm64"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Set to true if you want to force delete resources created by this module | `bool` | `false` | no |
| <a name="input_open_search_props"></a> [open\_search\_props](#input\_open\_search\_props) | Properties for the OpenSearch configuration | `any` | <pre>{<br>  "cluster_config": {<br>    "dedicated_master_count": 4,<br>    "dedicated_master_enabled": true,<br>    "dedicated_master_type": "c6g.large.search",<br>    "instance_count": 4,<br>    "instance_type": "r6g.large.search",<br>    "zone_awareness_config": {<br>      "availability_zone_count": 2<br>    },<br>    "zone_awareness_enabled": true<br>  },<br>  "collection_name": "rag-collection",<br>  "domain_name": "opensearch",<br>  "ebs_options": {<br>    "ebs_enabled": true,<br>    "volume_size": 10,<br>    "volume_type": "gp3"<br>  },<br>  "engine_version": "OpenSearch_1.0",<br>  "index_name": "doc-rag-search",<br>  "open_search_service_type": "aoss",<br>  "secret": "NONE",<br>  "standby_replicas": 2<br>}</pre> | no |
| <a name="input_solution_prefix"></a> [solution\_prefix](#input\_solution\_prefix) | Prefix to be included in all resources deployed by this solution | `string` | `"aws-ia"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to resources deployed by this solution. | `map(any)` | `null` | no |
| <a name="input_vpc_props"></a> [vpc\_props](#input\_vpc\_props) | Properties for the VPC to be deployed. Error if both this and 'deploy\_vpc' are provided | `any` | <pre>{<br>  "az_count": 2,<br>  "cidr_block": "10.0.0.0/20",<br>  "subnets": {<br>    "private": {<br>      "connect_to_public_natgw": true,<br>      "netmask": 24<br>    },<br>    "public": {<br>      "nat_gateway_configuration": "all_azs",<br>      "netmask": 24<br>    }<br>  },<br>  "vpc_flow_logs": {<br>    "log_destination_type": "cloud-watch-logs",<br>    "retention_in_days": 180<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognito_user_client_secret"></a> [cognito\_user\_client\_secret](#output\_cognito\_user\_client\_secret) | ARN of the AWS Secrets Manager secret for Cognito client secret key |
<!-- END_TF_DOCS -->
