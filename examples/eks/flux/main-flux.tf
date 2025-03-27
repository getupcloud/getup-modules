# File auto-generated by ./bin/make-example-main for $eks cluster

module "flux" {
  source = "git@github.com:getupcloud/getup-modules//modules/eks/flux?ref=v1.2.3"

  flux_aws_region        = var.aws_region
  flux_cluster_name      = module.eks.cluster_name
  flux_github_token      = var.flux_github_token
  flux_github_org        = var.flux_github_org
  flux_github_repository = var.flux_github_repository
  flux_path              = var.flux_path
  flux_version           = var.flux_version
}
