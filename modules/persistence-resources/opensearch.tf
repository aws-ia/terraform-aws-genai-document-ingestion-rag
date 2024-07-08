# TODO: use CME KMS, maybe to remove it
module "opensearch" {
  count = var.open_search_service_type == "es" ? 1 : 0

  source  = "terraform-aws-modules/opensearch/aws"
  version = "1.3.1"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  advanced_security_options = {
    enabled                = true
    anonymous_auth_enabled = true

    master_user_options = {
      master_user_arn = var.open_search_props.master_user_arn
    }
  }

  cluster_config = var.open_search_props.cluster_config

  domain_endpoint_options = {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  domain_name = local.opensearch.domain_name

  ebs_options = var.open_search_props.ebs_options

  encrypt_at_rest = {
    enabled = true
  }

  engine_version = var.open_search_props.engine_version

  node_to_node_encryption = {
    enabled = true
  }

  vpc_options = {
    subnet_ids = var.open_search_props.subnet_ids
  }

  access_policy_statements = data.aws_iam_policy_document.opensearch_domain_policy[count.index].statement

  tags = local.combined_tags
}

resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  count       = var.open_search_service_type == "aoss" ? 1 : 0
  name        = local.opensearch_serverless.collection_name
  type        = "encryption"
  description = "encryption policy for ${local.opensearch_serverless.collection_name}"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${local.opensearch_serverless.collection_name}"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = false
    KmsARN      = aws_kms_alias.app_kms_key.target_key_arn
  })
}

resource "aws_opensearchserverless_security_policy" "collection_policy" {
  count = var.open_search_service_type == "aoss" ? 1 : 0
  name  = local.opensearch_serverless.collection_name
  type  = "network"
  policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.opensearch_serverless.collection_name}"
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
            "collection/${local.opensearch_serverless.collection_name}"
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

resource "aws_opensearchserverless_collection" "opensearch_serverless_collection" {
  count = var.open_search_service_type == "aoss" ? 1 : 0
  name  = local.opensearch_serverless.collection_name
  type  = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.collection_policy,
    aws_opensearchserverless_security_policy.encryption_policy
  ]

  tags = local.combined_tags
}