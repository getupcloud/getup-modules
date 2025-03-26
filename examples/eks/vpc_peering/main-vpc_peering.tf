# File auto-generated by ./bin/make-example-main for $eks cluster

module "vpc_peering" {
  source = "git@github.com:getupcloud/getup-modules//modules/eks/vpc_peering?ref=v1.2.0"

  vpc_peering_owner_vpc_id          = var.vpc_peering_owner_vpc_id
  vpc_peering_owner_route_table_ids = var.vpc_peering_owner_route_table_ids
  vpc_peering_peer_vpc_id           = var.vpc_peering_peer_vpc_id
  vpc_peering_peer_route_table_ids  = var.vpc_peering_peer_route_table_ids
  vpc_peering_tags                  = var.vpc_peering_tags
}
