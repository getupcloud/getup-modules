locals {
  name_prefix = "loki-"
}

module "loki_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket_prefix = local.name_prefix
  force_destroy = true

  lifecycle_rule = [for idx, prefix in var.loki_retention_prefixes :
    {
      id      = "expiration-${idx}-${var.loki_retention_days}-days"
      enabled = true
      filter = {
        prefix = prefix
      }
      expiration = {
        days = var.loki_retention_days
      }
    }
  ]

  tags = merge(var.loki_tags, {
    "managed-by" : "terraform"
  })
}

data "aws_iam_policy_document" "loki_s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      module.loki_s3_bucket.s3_bucket_arn,
      "${module.loki_s3_bucket.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "loki_s3" {
  name_prefix = local.name_prefix
  description = "AWSS3Loki policy"
  policy      = data.aws_iam_policy_document.loki_s3.json

  tags = merge(var.loki_tags, {
    "managed-by" : "terraform"
  })
}


module "loki_s3_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.loki_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.loki_s3.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:logging:loki"] #TODO: parametrize

  tags = merge(var.loki_tags, {
    "managed-by" : "terraform"
  })
}

