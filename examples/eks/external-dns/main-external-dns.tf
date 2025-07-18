# File auto-generated by command: ./bin/make-example main eks external-dns v2.1.5

module "external-dns" {
  source = "git@github.com:getupcloud/getup-modules//modules/eks/external-dns?ref=v2.1.5"

  external_dns_cluster_oidc_issuer_url = module.eks.eks_cluster_oidc_issuer_url
  external_dns_namespace               = var.external_dns_namespace
  external_dns_service_account         = var.external_dns_service_account
  external_dns_aws_region              = var.external_dns_aws_region
  external_dns_aws_account_id          = var.external_dns_aws_account_id
  external_dns_hosted_zone_ids         = var.external_dns_hosted_zone_ids
  external_dns_tags                    = var.external_dns_tags
}
