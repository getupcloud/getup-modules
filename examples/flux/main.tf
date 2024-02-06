# File auto-generated from ./bin/module2example

module "flux" {
  source = "github.com/getupcloud/terraform-modules//modules/flux?ref=v0.2.3"

  flux_aws_region        = var.flux_aws_region
  flux_cluster_name      = var.flux_cluster_name
  flux_github_token      = var.flux_github_token
  flux_github_org        = var.flux_github_org
  flux_github_repository = var.flux_github_repository
  flux_path              = var.flux_path
}
