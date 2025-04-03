module "doks" {
  source = "../../modules/doks/doks"

  cluster_name = "test"
  region       = "nyc3"
  vpc_name     = "vpc123"
}

#module "flux" {
#  source = "../modules/flux"
#
#  flux_aws_region   = "us-east-1"
#  flux_cluster_name = "test"
#}

module "loki" {
  source             = "../../modules/doks/loki"
  loki_bucket_region = "nyc3"
}

module "velero" {
  source = "../../modules/doks/velero"

  velero_bucket_region = "nyc3"
}

module "tempo" {
  source = "../../modules/doks/tempo"

  tempo_bucket_region = "nyc3"
}

#module "vpc_peering" {
#  source = "../modules/vpc_peering"
#
#  vpc_peering_owner_vpc_id          = "vpc-000000000"
#  vpc_peering_peer_vpc_id           = "vpc-000000000"
#  vpc_peering_owner_route_table_ids = ["rtb-00000000"]
#  vpc_peering_peer_route_table_ids  = ["rtb-00000000"]
#}
