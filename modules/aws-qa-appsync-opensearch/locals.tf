locals {
  # Boolean values for conditions
  existing_input_assets_bucket_obj_bool = var.existing_input_assets_bucket_obj != null ? length(tolist([var.existing_input_assets_bucket_obj])) > 0 : false
  existing_bucket_interface_bool = var.existing_bucket_interface != null ? length(tolist([var.existing_bucket_interface])) > 0 : false
  bucket_inputs_assets_props_bool = var.bucket_inputs_assets_props != null ? length(tolist([var.bucket_inputs_assets_props])) > 0 : false
  bucket_props_bool = var.bucket_props != null ? length(tolist([var.bucket_props])) > 0 : false
  existing_logging_bucket_obj_bool = var.existing_logging_bucket_obj != null ? length(tolist([var.existing_logging_bucket_obj])) > 0 : false
  logging_bucket_props_bool = var.logging_bucket_props != null ? length(tolist([var.logging_bucket_props])) > 0 : false
  log_s3_access_logs_bool = var.log_s3_access_logs != null ? length(tolist([var.log_s3_access_logs])) > 0 : false
  vpc_props_bool = var.vpc_props != null ? length(tolist([var.vpc_props])) > 0 : false
  existing_vpc_bool = var.existing_vpc != null ? length(tolist([var.existing_vpc])) > 0 : false
  existing_security_group_id_bool = var.existing_security_group_id != null ? length(tolist([var.existing_security_group_id])) > 0 : false
  existing_bus_interface_bool = var.existing_bus_interface != null ? length(tolist([var.existing_bus_interface])) > 0 : false
  open_search_secret_bool = var.open_search_secret != null ? length(tolist([var.open_search_secret])) > 0 : false
  existing_merged_api_bool = var.existing_merged_api != null ? length(tolist([var.existing_merged_api])) > 0 : false
#   Errors handling
  error_messages = compact([
    (local.existing_input_assets_bucket_obj_bool && (local.existing_bucket_interface_bool || local.bucket_props_bool)) ? "Error - Either provide bucket_props or existing_input_assets_bucket_obj, but not both." : null,
    (local.existing_logging_bucket_obj_bool && local.logging_bucket_props_bool) ? "Error - Either provide existing_logging_bucket_obj or logging_bucket_props, but not both." : null,
    (!local.log_s3_access_logs_bool && (local.logging_bucket_props_bool || local.existing_logging_bucket_obj_bool)) ? "Error - If log_s3_access_logs is false, supplying logging_bucket_props or existing_logging_bucket_obj is invalid." : null,
    (local.existing_input_assets_bucket_obj_bool && (local.logging_bucket_props_bool || local.log_s3_access_logs_bool)) ? "Error - If existing_input_assets_bucket_obj is provided, supplying logging_bucket_props or log_s3_access_logs is an error." : null,
    ((coalesce(var.deploy_vpc, true) || local.vpc_props_bool) && local.existing_vpc_bool) ? "Error - Either provide an existingVpc or some combination of deployVpc and vpcProps, but not both." : null
  ])
  security_group_id = local.existing_security_group_id_bool ? var.existing_security_group_id : aws_security_group.security_group.id
  vpc_id = local.existing_vpc_bool ? var.existing_vpc.id : aws_vpc.vpc.id
  input_assets_bucket_name = local.existing_input_assets_bucket_obj_bool ? var.existing_input_assets_bucket_obj.bucket : aws_s3_bucket.input_assets_qa_bucket.bucket
  input_assets_bucket_id = local.existing_input_assets_bucket_obj_bool ? var.existing_input_assets_bucket_obj.id : aws_s3_bucket.input_assets_qa_bucket.id
  qa_bus = local.existing_bus_interface_bool ? var.existing_bus_interface : aws_cloudwatch_event_bus.question_answering_event_bus
  secret_id = local.open_search_secret_bool ? var.open_search_secret.secret_name : "NONE"
  enable_operational_metric = coalesce(var.enable_operational_metric, true)
  version = var.project_version
  solution_id = local.enable_operational_metric ? "genai_cdk_${local.version}/${var.constructor_name}/${var.id}" : null
  graph_ql_id = local.existing_merged_api_bool ? var.existing_merged_api.id : aws_appsync_graphql_api.question_answering_graphql_api.id
}
