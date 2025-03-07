# File auto-generated by ./bin/make-example-main

module "loki" {
  source = "git@github.com:getupcloud/terraform-modules//modules/loki?ref=v0.23.5"

  loki_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  loki_tags                    = var.loki_tags
  loki_retention_days          = var.loki_retention_days
  loki_retention_prefixes      = var.loki_retention_prefixes
}
