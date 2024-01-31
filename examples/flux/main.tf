# File auto-generated from ./bin/module2example

module "flux" {
  source = "github.com/getupcloud/terraform-modules//modules/flux?ref=v0.0.11"

  aws_region                         = var.aws_region
  cluster_name                       = var.cluster_name
  cluster_endpoint                   = var.cluster_endpoint
  cluster_certificate_authority_data = var.cluster_certificate_authority_data
  flux_github_token                  = var.flux_github_token
  flux_github_org                    = var.flux_github_org
  flux_github_repository             = var.flux_github_repository
  flux_path                          = var.flux_path
}
