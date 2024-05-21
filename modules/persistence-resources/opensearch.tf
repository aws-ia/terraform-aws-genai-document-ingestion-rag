resource "aws_opensearch_domain" "opensearch_domain" {
  count          = var.open_search-service_type == "es" ? 1 : 0
  domain_name    = var.open_search_domain_name
  engine_version = "OpenSearch_1.0"
  cluster_config {
    instance_type            = var.open_search_props["master_node_instance_type"]
    instance_count           = var.open_search_props["master_nodes"]
    dedicated_master_enabled = true
    dedicated_master_type    = var.open_search_props["master_node_instance_type"]
    dedicated_master_count   = var.open_search_props["master_nodes"]
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.open_search_props["volume_size"]
  }

  vpc_options {
    subnet_ids = [
      var.isolated_subnet_id,
      var.private_subnet_id,
      var.public_subnet_id
    ]
    security_group_ids = [var.primary_security_group_id, var.lambda_security_group_id]
  }
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  node_to_node_encryption {
    enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  access_policies = data.aws_iam_policy_document.opensearch_domain_policy
}

resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = "${var.open_search_props.collection_name}-encryption-policy"
  type        = "encryption"
  description = "encryption policy for ${var.open_search_props.collection_name}"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.open_search_props.collection_name}"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}


resource "aws_opensearchserverless_security_policy" "opensearch_serverless_collection_policy" {
  count = var.open_search-service_type == "aoss" ? 1 : 0
  name = "${var.open_search_props.collection_name}-collection-policy"
  type = "network"
    policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${var.open_search_props.collection_name}"
          ]
        }
      ],
      AllowFromPublic = false,
      SourceVPCEs = [
        var.open_search_props.open_search_vpc_endpoint_id
      ]
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${var.open_search_props.collection_name}"
          ]
        }
      ],
      AllowFromPublic = false
      SourceVPCEs = [
        var.open_search_props.open_search_vpc_endpoint_id
      ]
    }
  ])
}

# resource "aws_opensearchserverless_security_policy" "opensearch_serverless_collection_policy" {
#   count = var.open_search-service_type == "aoss" ? 1 : 0
#   name = "${var.open_search_props.collection_name}-collection-policy"
#   type = "encryption"
#   policy = jsonencode({
#     "Rules" = [
#       {
#         Resource = [
#           "collection/${var.open_search_props.collection_name}"
#         ],
#         ResourceType = "collection"
#       },
#       {
#         Resource = [
#           "collection/${var.open_search_props.collection_name}"
#         ],
#         ResourceType = "dashboard"
#       }
#     ],
#     AllowFromPublic = false
#     "AWSOwnedKey" = true
#     SourceVPCEs = [
#         var.open_search_props.open_search_vpc_endpoint_id
#       ]
#   })
# }

resource "aws_opensearchserverless_collection" "opensearch_serverless_collection" {
  count = var.open_search-service_type == "aoss" ? 1 : 0
  name = var.open_search_props.collection_name
  type = "VECTORSEARCH"

  depends_on = [aws_opensearchserverless_security_policy.opensearch_serverless_collection_policy]
}