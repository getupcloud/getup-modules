locals {
  name_prefix = "external-secrets-operator-"
  policy_vars = {
    aws_region : var.aws_eso_aws_region != "" ? var.aws_eso_aws_region : data.aws_region.current.name
    aws_account_id : var.aws_eso_aws_account_id != "" ? var.aws_eso_aws_account_id : data.aws_caller_identity.current.account_id
    secrets : compact(concat(var.aws_eso_secrets, var.aws_eso_create_secrets))
    secrets_arns : concat(
      [for s in var.aws_eso_secrets : s if startswith(s, "arn:")],
      flatten([for s in data.aws_secretsmanager_secrets.secrets : s.arns]),
      [for s in module.secrets : s.secret_arn]
    )
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_secretsmanager_secrets" "secrets" {
  for_each = toset([for s in var.aws_eso_secrets : s if !startswith(s, "arn:")])

  filter {
    name   = "name"
    values = [each.key]
  }
}

resource "aws_iam_policy" "policy" {
  name_prefix = local.name_prefix
  description = "AWS External Secrets Operator policy for IRSA"
  policy      = templatefile("${path.module}/policy.json", local.policy_vars)

  tags = merge(var.aws_eso_tags, {
    "managed-by" : "terraform"
  })
}

module "aws_eso_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.aws_eso_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.aws_eso_namespace}:${var.aws_eso_service_account}"]

  tags = merge(var.aws_eso_tags, {
    "managed-by" : "terraform"
  })
}

module "secrets" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 1.1"

  for_each = toset(var.aws_eso_create_secrets)

  # Secret
  name                    = each.key
  description             = "Secrets Manager for EKS (${var.aws_eso_cluster_oidc_issuer_url})"
  recovery_window_in_days = 7
  secret_string           = jsonencode({ "EXAMPLE" : "example-data" })

  # Policy
  ignore_secret_changes = true
  block_public_policy   = true

  tags = merge(var.aws_eso_tags, {
    "managed-by" : "terraform"
  })
}
