locals {
  vpc_create = var.vpc_uuid == "" && var.vpc_name != ""
  vpc_uuid   = local.vpc_create ? digitalocean_vpc.vpc[0].id : var.vpc_uuid
  tags       = [for k, v in var.tags : "${k}:${v}"]
}

