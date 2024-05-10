<!-- BEGIN_TF_DOCS -->
# Terraform Module Project

:no\_entry\_sign: Do not edit this readme.md file. To learn how to change this content and work with this repository, refer to CONTRIBUTING.md

## Readme Content

This file will contain any instructional information about this module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_my_module"></a> [my\_module](#module\_my\_module) | ./modules/aws-qa-appsync-opensearch | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_constructor_name"></a> [constructor\_name](#input\_constructor\_name) | Name of the constructor | `string` | n/a | yes |
| <a name="input_id"></a> [id](#input\_id) | ID for the resource | `string` | n/a | yes |
| <a name="input_project_version"></a> [project\_version](#input\_project\_version) | Version of the project | `string` | n/a | yes |
| <a name="input_api_log_config"></a> [api\_log\_config](#input\_api\_log\_config) | Configuration for API logging, default is null | `any` | `null` | no |
| <a name="input_bucket_inputs_assets_props"></a> [bucket\_inputs\_assets\_props](#input\_bucket\_inputs\_assets\_props) | Properties for the input assets bucket, default is null | `any` | `null` | no |
| <a name="input_bucket_props"></a> [bucket\_props](#input\_bucket\_props) | Properties for the bucket, default is null | `any` | `null` | no |
| <a name="input_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#input\_cognito\_user\_pool\_id) | ID for the Cognito user pool, default is 'test\_cognito\_user\_pool\_id' | `string` | `"test_cognito_user_pool_id"` | no |
| <a name="input_deploy_vpc"></a> [deploy\_vpc](#input\_deploy\_vpc) | Specify if a VPC should be deployed, default is null | `bool` | `null` | no |
| <a name="input_enable_operational_metric"></a> [enable\_operational\_metric](#input\_enable\_operational\_metric) | Enable or disable operational metric, default is null | `any` | `null` | no |
| <a name="input_enable_xray"></a> [enable\_xray](#input\_enable\_xray) | Enable or disable X-Ray, default is true | `bool` | `true` | no |
| <a name="input_existing_bucket_interface"></a> [existing\_bucket\_interface](#input\_existing\_bucket\_interface) | Existing bucket interface to be used, default is null | `any` | `null` | no |
| <a name="input_existing_bus_interface"></a> [existing\_bus\_interface](#input\_existing\_bus\_interface) | Existing bus interface to be used, default is null | `any` | `null` | no |
| <a name="input_existing_input_assets_bucket_obj"></a> [existing\_input\_assets\_bucket\_obj](#input\_existing\_input\_assets\_bucket\_obj) | Existing input assets bucket to be used. Provide 'bucket' and 'id' based on your configuration needs | <pre>object({<br>    bucket: string<br>    id: string<br>  })</pre> | `null` | no |
| <a name="input_existing_logging_bucket_obj"></a> [existing\_logging\_bucket\_obj](#input\_existing\_logging\_bucket\_obj) | Existing logging bucket to be used, default is null | `any` | `null` | no |
| <a name="input_existing_merged_api"></a> [existing\_merged\_api](#input\_existing\_merged\_api) | Existing merged API to be used. Provide 'id' and 'url' based on your configuration needs | <pre>object({<br>    id: string<br>    url: string<br>  })</pre> | `null` | no |
| <a name="input_existing_opensearch_domain"></a> [existing\_opensearch\_domain](#input\_existing\_opensearch\_domain) | Existing OpenSearch domain to be used. Provide 'domain\_name' and 'endpoint' based on your configuration needs | <pre>object({<br>    domain_name: string<br>    endpoint: string<br>  })</pre> | <pre>{<br>  "domain_name": "test_name",<br>  "endpoint": "test_endpoint"<br>}</pre> | no |
| <a name="input_existing_security_group_id"></a> [existing\_security\_group\_id](#input\_existing\_security\_group\_id) | Existing security group to be used, default is null | `any` | `null` | no |
| <a name="input_existing_vpc"></a> [existing\_vpc](#input\_existing\_vpc) | Existing VPC to be used. If not provided, a new one will be created | <pre>object({<br>    id: string<br>  })</pre> | `null` | no |
| <a name="input_log_s3_access_logs"></a> [log\_s3\_access\_logs](#input\_log\_s3\_access\_logs) | Enable or disable logging of S3 access logs, default is null | `any` | `null` | no |
| <a name="input_logging_bucket_props"></a> [logging\_bucket\_props](#input\_logging\_bucket\_props) | Properties for the logging bucket, default is null | `any` | `null` | no |
| <a name="input_observability"></a> [observability](#input\_observability) | Enable or disable observability, default is true | `bool` | `true` | no |
| <a name="input_open_search_index_name"></a> [open\_search\_index\_name](#input\_open\_search\_index\_name) | Name for the OpenSearch index, default is 'test\_open\_search\_index\_name' | `string` | `"test_open_search_index_name"` | no |
| <a name="input_open_search_secret"></a> [open\_search\_secret](#input\_open\_search\_secret) | Secret for OpenSearch. Provide 'arn' and 'secret\_name' based on your configuration needs | <pre>object({<br>    arn: string<br>    secret_name: string<br>  })</pre> | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | The stage for the deployment, default is '-dev' | `string` | `"_dev"` | no |
| <a name="input_use_existing_merged_api"></a> [use\_existing\_merged\_api](#input\_use\_existing\_merged\_api) | Use existing merged API, default is false | `bool` | `false` | no |
| <a name="input_vpc_props"></a> [vpc\_props](#input\_vpc\_props) | Properties for the VPC to be deployed. Error if both this and 'deploy\_vpc' are provided | <pre>object({<br>    name: string<br>    cidr_block: string<br>  })</pre> | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->