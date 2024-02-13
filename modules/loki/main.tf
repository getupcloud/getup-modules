locals {
  name_prefix = "loki-"
}

resource "aws_s3_bucket" "s3_loki" {
  bucket_prefix = local.name_prefix

}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix = local.name_prefix
  force_destroy = true

  lifecycle_rule = [for idx, prefix in var.loki_retention_prefixes : {
    id      = "expiration-${idx}"
    enabled = true
    filter = {
      prefix = prefix
    }
    expiration = {
      days                         = var.loki_retention_days
      expired_object_delete_marker = true
    }
    }
  ]

  tags = merge(var.loki_tags, {
    "managed-by" : "terraform"
  })
}

data "aws_iam_policy_document" "s3_loki" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.s3_loki.arn,
      "${aws_s3_bucket.s3_loki.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_loki" {
  name_prefix = local.name_prefix
  description = "AWSS3Loki policy"
  policy      = data.aws_iam_policy_document.s3_loki.json
}


module "loki_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34.0"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.loki_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.s3_loki.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:logging:loki"]
}

