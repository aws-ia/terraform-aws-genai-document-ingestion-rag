# resource "null_resource" "create_merged_api" {
#   provisioner "local-exec" {
#     command = <<EOT
#       if ! aws appsync list-graphql-apis --query "graphqlApis[?name=='${var.merged_api_name}'].apiId" --output text --region ${data.aws_region.current.name} | grep -q .; then
#         aws appsync create-graphql-api \
#           --name ${var.merged_api_name} \
#           --authentication-type AMAZON_COGNITO_USER_POOLS \
#           --user-pool-config awsRegion=${data.aws_region.current.name},defaultAction=ALLOW,userPoolId=${aws_cognito_user_pool.user_pool.id} \
#           --additional-authentication-providers authenticationType=AWS_IAM \
#           --xray-enabled \
#           --log-config fieldLogLevel=ALL,cloudWatchLogsRoleArn=${aws_iam_role.appsync_execution_role.arn} \
#           --region ${data.aws_region.current.name} \
#           --api-type MERGED \
#           --merged-api-execution-role-arn ${aws_iam_role.appsync_execution_role.arn}
#       fi
#     EOT

#   }

#   triggers = {
#     always_run = timestamp()
#   }
# }

# resource "null_resource" "get_merged_api_id" {
#   provisioner "local-exec" {
#     command = <<EOT
#       aws appsync list-graphql-apis --region ${data.aws_region.current.name}  --query "graphqlApis[?name=='MergedGraphqlApi'].apiId" --output text > merged_api_id.txt
#     EOT
#   }

#   depends_on = [null_resource.create_merged_api]

#   triggers = {
#     always_run = timestamp()
#   }
# }

# resource "null_resource" "get_merged_api_url" {
#   provisioner "local-exec" {
#     command = <<EOT
#       aws appsync get-graphql-api --api-id $(cat merged_api_id.txt) --region ${data.aws_region.current.name} --query "graphqlApi.uris.GRAPHQL" --output text > merged_api_url.txt
#     EOT
#   }
#   depends_on = [null_resource.get_merged_api_id]
#   triggers = {
#     always_run = timestamp()
#   }
# }
