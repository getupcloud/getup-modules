# File auto-generated by ./bin/make-example-main for $eks cluster

module "argocd" {
  source = "git@github.com:getupcloud/getup-modules//modules/eks/argocd?ref=v1.2.6"

  argocd_repository = var.argocd_repository
  argocd_version    = var.argocd_version
  argocd_namespace  = var.argocd_namespace
  argocd_values     = var.argocd_values
  argocd_set        = var.argocd_set
  argocd_set_list   = var.argocd_set_list
}
