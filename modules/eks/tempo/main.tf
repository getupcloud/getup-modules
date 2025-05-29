locals {
  name_prefix = "tempo-"
}

module "tempo_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket_prefix = local.name_prefix
  force_destroy = true

  tags = merge(var.tempo_tags, {
    "managed-by" : "terraform"
  })
}

data "aws_iam_policy_document" "tempo_s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      module.tempo_s3_bucket.s3_bucket_arn,
      "${module.tempo_s3_bucket.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "tempo_s3" {
  name_prefix = local.name_prefix
  description = "AWSS3Tempo policy"
  policy      = data.aws_iam_policy_document.tempo_s3.json

  tags = merge(var.tempo_tags, {
    "managed-by" : "terraform"
  })
}


module "tempo_s3_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.tempo_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.tempo_s3.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:tempo"] #TODO: parametrize

  tags = merge(var.tempo_tags, {
    "managed-by" : "terraform"
  })
}

