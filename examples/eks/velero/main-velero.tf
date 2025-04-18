# File auto-generated by ./bin/make-example-main for $eks cluster

module "velero" {
  source = "git@github.com:getupcloud/getup-modules//modules/eks/velero?ref=v1.2.11"

  velero_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  velero_tags                    = var.velero_tags
  velero_retention_days          = var.velero_retention_days
  velero_retention_prefixes      = var.velero_retention_prefixes
}
