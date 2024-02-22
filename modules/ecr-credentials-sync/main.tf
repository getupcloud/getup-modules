locals {
  name_prefix        = "ecr-credentials-sync-"
  ecr_managed_policy = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

module "ecr_credentials_sync" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34.0"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.ecr_credentials_sync_cluster_oidc_issuer_url
  role_policy_arns              = [local.ecr_managed_policy]
  oidc_fully_qualified_subjects = ["system:serviceaccount:flux-system:ecr-credentials-sync"] #TODO: parametrize

  tags = merge(var.ecr_credentials_sync_tags, {
    "managed-by" : "terraform"
  })
}

