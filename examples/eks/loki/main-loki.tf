# File auto-generated by ./bin/make-example-main for $eks cluster

module "loki" {
  source = "git@github.com:getupcloud/getup-modules//modules/eks/loki?ref=v1.2.3"

  loki_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  loki_tags                    = var.loki_tags
  loki_retention_days          = var.loki_retention_days
  loki_retention_prefixes      = var.loki_retention_prefixes
}
