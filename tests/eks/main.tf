module "argocd" {
  source = "../../modules/eks/argocd"
}

module "aws-external-secrets-operator" {
  source = "../../modules/eks/aws-external-secrets-operator"

  aws_eso_cluster_oidc_issuer_url = "localhost"
}

module "cert-manager" {
  source = "../../modules/eks/cert-manager"

  cert_manager_cluster_oidc_issuer_url = "localhost"
}

module "ecr-credentials-sync" {
  source = "../../modules/eks/ecr-credentials-sync"

  ecr_credentials_sync_cluster_oidc_issuer_url = "localhost"
}

module "eks" {
  source = "../../modules/eks/eks"

  cluster_name   = "test"
  aws_account_id = "0000000000"
  aws_region     = "us-east-1"
  vpc_zones      = ["us-east-1a", "us-east-1b"]
}

#module "flux" {
#  source = "../modules/flux"
#
#  flux_aws_region   = "us-east-1"
#  flux_cluster_name = "test"
#}

module "istio" {
  source = "../../modules/eks/istio"
}

module "loki" {
  source = "../../modules/eks/loki"

  loki_cluster_oidc_issuer_url = "localhost"
}

module "velero" {
  source = "../../modules/eks/velero"

  velero_cluster_oidc_issuer_url = "localhost"
}

module "opencost" {
  source = "../../modules/eks/opencost"

  opencost_cluster_oidc_issuer_url   = "localhost"
  opencost_spot_datafeed_bucket_name = "test"
}

module "rds" {
  source = "../../modules/eks/rds"

  rds_name = "test"
}

module "tempo" {
  source = "../../modules/eks/tempo"

  tempo_cluster_oidc_issuer_url = "localhost"
}

#module "vpc_peering" {
#  source = "../modules/vpc_peering"
#
#  vpc_peering_owner_vpc_id          = "vpc-000000000"
#  vpc_peering_peer_vpc_id           = "vpc-000000000"
#  vpc_peering_owner_route_table_ids = ["rtb-00000000"]
#  vpc_peering_peer_route_table_ids  = ["rtb-00000000"]
#}
