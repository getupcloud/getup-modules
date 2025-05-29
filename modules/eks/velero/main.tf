locals {
  name_prefix = "velero-"
}

module "velero_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket_prefix = local.name_prefix
  force_destroy = true

  lifecycle_rule = [for idx, prefix in var.velero_retention_prefixes :
    {
      id      = "expiration-${idx}-${var.velero_retention_days}-days"
      enabled = true
      filter = {
        prefix = prefix
      }
      expiration = {
        days = var.velero_retention_days
      }
    }
  ]

  tags = merge(var.velero_tags, {
    "managed-by" : "terraform"
  })
}

data "aws_iam_policy_document" "aws_velero" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]

    resources = [
      module.velero_s3_bucket.s3_bucket_arn,
      "${module.velero_s3_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      module.velero_s3_bucket.s3_bucket_arn,
      "${module.velero_s3_bucket.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "velero_s3" {
  name_prefix = local.name_prefix
  description = "AWSS3Velero policy"
  policy      = data.aws_iam_policy_document.aws_velero.json

  tags = merge(var.velero_tags, {
    "managed-by" : "terraform"
  })
}


module "velero_s3_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.velero_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.velero_s3.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:velero:velero"] #TODO: parametrize

  tags = merge(var.velero_tags, {
    "managed-by" : "terraform"
  })
}

