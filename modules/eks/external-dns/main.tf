locals {
  name_prefix = "external-dns-"
  policy_vars = {
    ## Add variables to replace inside the policy.json file
    external_dns_hosted_zone_arns = length(var.external_dns_hosted_zone_ids) == 0 ? ["arn:aws:route53:::hostedzone/*"] : [
      for id in var.external_dns_hosted_zone_ids : "arn:aws:route53:::hostedzone/${id}"
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name_prefix = local.name_prefix
  description = "External DNS policy for IRSA"
  policy      = templatefile("${path.module}/policy.json", local.policy_vars)

  tags = merge(var.external_dns_tags, {
    "managed-by" : "terraform"
  })
}

module "external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.external_dns_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.external_dns_namespace}:${var.external_dns_service_account}"]

  tags = merge(var.external_dns_tags, {
    "managed-by" : "terraform"
  })
}

