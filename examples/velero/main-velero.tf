# File auto-generated by ./bin/make-example-main

module "velero" {
  source = "git@github.com:getupcloud/terraform-modules//modules/velero?ref=v0.23.6"

  velero_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  velero_tags                    = var.velero_tags
  velero_retention_days          = var.velero_retention_days
  velero_retention_prefixes      = var.velero_retention_prefixes
}
