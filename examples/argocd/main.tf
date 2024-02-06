# File auto-generated from ./bin/module2example

module "argocd" {
  source = "github.com/getupcloud/terraform-modules//modules/argocd?ref=v0.3.1"

  argocd_repository = var.argocd_repository
  argocd_version    = var.argocd_version
  argocd_namespace  = var.argocd_namespace
  argocd_values     = var.argocd_values
  argocd_set        = var.argocd_set
  argocd_set_list   = var.argocd_set_list
}
