data "aws_vpc" "owner" {
  count = length(var.vpc_peering_owner_route_table_ids) > 0 ? 1 : 0
  id    = var.vpc_peering_owner_vpc_id
}

data "aws_vpc" "peer" {
  count = length(var.vpc_peering_peer_route_table_ids) > 0 ? 1 : 0
  id    = var.vpc_peering_peer_vpc_id
}

resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = var.vpc_peering_owner_vpc_id
  peer_vpc_id = var.vpc_peering_peer_vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "owner" {
  for_each = toset(var.vpc_peering_owner_route_table_ids)

  route_table_id            = each.key
  destination_cidr_block    = data.aws_vpc.peer[0].cidr_block
  vpc_peering_connection_id = resource.aws_vpc_peering_connection.peering.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "peer" {
  for_each = toset(var.vpc_peering_peer_route_table_ids)

  route_table_id            = each.key
  destination_cidr_block    = data.aws_vpc.owner[0].cidr_block
  vpc_peering_connection_id = resource.aws_vpc_peering_connection.peering.id

  timeouts {
    create = "5m"
  }
}
