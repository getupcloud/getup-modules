locals {
  name_prefix = "opencost-${var.opencost_cluster_name}-"
  policy_vars = {
    ## Add variables to replace inside the policy.json file
    opencost_bucket_name : var.opencost_spot_datafeed_bucket_name
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "policy" {
  name_prefix = local.name_prefix
  description = "OpenCost policy for IRSA"
  policy      = templatefile("${path.module}/policy.json", local.policy_vars)

  tags = merge(var.opencost_tags, {
    "managed-by" : "terraform"
  })
}


module "opencost_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34.0"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.opencost_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.opencost_namespace}:${var.opencost_service_account}"]

  tags = merge(var.opencost_tags, {
    "managed-by" : "terraform"
  })
}

module "opencost_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"
  count   = var.opencost_create_spot_datafeed_bucket ? 1 : 0

  bucket                   = var.opencost_spot_datafeed_bucket_name
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
  force_destroy            = false

  lifecycle_rule = [{
    id      = "expiration-${var.opencost_spot_datafeed_retention_days}-days"
    enabled = true
    filter = {
      prefix = var.opencost_spot_datafeed_prefix
    }
    expiration = {
      days = var.opencost_spot_datafeed_retention_days
    }
  }]

  tags = merge(var.opencost_tags, {
    "managed-by" : "terraform",
    "created-by" : "${var.opencost_cluster_name != "" ? var.opencost_cluster_name : var.opencost_cluster_oidc_issuer_url}/${data.aws_region.current.name}"
  })
}

resource "aws_spot_datafeed_subscription" "opencost" {
  count = var.opencost_create_spot_datafeed_bucket ? 1 : 0

  bucket = module.opencost_s3_bucket[0].s3_bucket_id
  prefix = var.opencost_spot_datafeed_prefix

  depends_on = [
    module.opencost_s3_bucket,
    module.opencost_irsa
  ]
}
