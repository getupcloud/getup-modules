locals {
  name_prefix = "aws-external-secrets-operator-"
  policy_vars = {
    aws_region : var.aws_eso_aws_region != "" ? var.aws_eso_aws_region : data.aws_region.current.name
    aws_account_id : var.aws_eso_aws_account_id != "" ? var.aws_eso_aws_account_id : data.aws_caller_identity.current.account_id
    all_secrets_managers : toset(compact(concat(var.aws_eso_secrets_managers, var.aws_eso_create_secrets_managers)))
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "policy" {
  name_prefix = local.name_prefix
  description = "AWS External Secrets Operator policy for IRSA"
  policy      = templatefile("${path.module}/policy.json", local.policy_vars)

  lifecycle {
    precondition {
      condition     = length(local.policy_vars.all_secrets_managers) >= 0
      error_message = "The selected AMI must be for the x86_64 architecture."
    }
  }

  tags = merge(var.aws_eso_tags, {
    "managed-by" : "terraform"
  })
}


module "aws_eso_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34.0"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.aws_eso_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.aws_eso_namespace}:${var.aws_eso_service_account}"]

  tags = merge(var.aws_eso_tags, {
    "managed-by" : "terraform"
  })
}

module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 1.1.1"

  for_each = toset(var.aws_eso_create_secrets_managers)

  # Secret
  name                    = each.key
  description             = "Secrets Manager for EKS (${var.aws_eso_cluster_oidc_issuer_url})"
  recovery_window_in_days = 30

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type = "AWS"
        identifiers = compact([
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        var.aws_eso_aws_account_id != "" ? var.aws_eso_aws_account_id : ""])
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  create_random_password           = true
  random_password_length           = 64
  random_password_override_special = "!@#$%^&*()_+"

  tags = merge(var.aws_eso_tags, {
    "managed-by" : "terraform"
  })
}
