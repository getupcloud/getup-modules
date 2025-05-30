# File auto-generated by command: ./bin/make-example main eks cert-manager v2.0.9

module "cert-manager" {
  source = "git@github.com:getupcloud/getup-modules//modules/eks/cert-manager?ref=v2.0.9"

  cert_manager_cluster_oidc_issuer_url = module.eks.eks_cluster_oidc_issuer_url
  cert_manager_tags                    = var.cert_manager_tags
}
