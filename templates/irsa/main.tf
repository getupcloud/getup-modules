locals {
  name_prefix = "${NAME}-"
  policy_vars = {
    ${name_}_aws_region: var.${name_}_aws_region != "" ? var.${name_}_aws_region : data.aws_region.current.name
    ${name_}_aws_account_id: var.${name_}_aws_account_id != "" ? var.${name_}_aws_account_id : data.aws_caller_identity.current.account_id
    ## Add variables to replace inside the policy.json file
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "policy" {
  name_prefix = local.name_prefix
  description = "${DISPLAY_NAME} policy for IRSA"
  policy      = templatefile("${path.module}/policy.json", local.policy_vars)

  tags = merge(var.${name_}_tags, {
    "managed-by" : "terraform"
  })
}


module "${name_}_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34.0"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.${name_}_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.${name_}_namespace}:${var.${name_}_service_account}"]

  tags = merge(var.${name_}_tags, {
    "managed-by" : "terraform"
  })
}

