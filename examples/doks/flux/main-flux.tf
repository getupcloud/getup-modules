# File auto-generated by ./bin/make-example-main for $doks cluster

module "flux" {
  source = "git@github.com:getupcloud/getup-modules//modules/doks/flux?ref=v1.1.5"

  flux_doks_region       = var.region
  flux_cluster_name      = module.doks.cluster_name
  flux_github_token      = var.flux_github_token
  flux_github_org        = var.flux_github_org
  flux_github_repository = var.flux_github_repository
  flux_path              = var.flux_path
  flux_version           = var.flux_version
}
