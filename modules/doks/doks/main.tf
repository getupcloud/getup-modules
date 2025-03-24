resource "digitalocean_vpc" "vpc" {
  count       = local.vpc_create ? 1 : 0
  name        = var.vpc_name
  region      = var.region
  ip_range    = var.vpc_ip_range
  description = var.vpc_description
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name          = var.cluster_name
  region        = var.region
  version       = var.kubernetes_version
  vpc_uuid      = local.vpc_uuid
  ha            = var.control_plane_ha
  auto_upgrade  = var.auto_upgrade
  surge_upgrade = var.surge_upgrade
  tags          = local.tags

  node_pool {
    name       = var.default_node_pool.name
    size       = var.default_node_pool.size
    auto_scale = var.default_node_pool.auto_scale
    node_count = var.default_node_pool.node_count
    min_nodes  = var.default_node_pool.min_nodes
    max_nodes  = var.default_node_pool.max_nodes
    labels     = try(var.default_node_pool.labels, {})
    tags       = distinct(concat(local.tags, [for k, v in var.default_node_pool.tags : "${k}:${v}"]))

    dynamic "taint" {
      for_each = try(var.default_node_pool.taints, [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }
}

resource "digitalocean_kubernetes_node_pool" "node_pool" {
  for_each = { for i, v in var.node_pools : v.name => v }

  cluster_id = digitalocean_kubernetes_cluster.cluster.id
  name       = try(each.value.name, "app-${each.key}")
  size       = try(each.value.size, "s-4vcpu-8gb")
  node_count = try(each.value.node_count, 2)
  auto_scale = try(each.value.auto_scale, true)
  min_nodes  = try(each.value.min_nodes, 2)
  max_nodes  = try(each.value.max_nodes, 4)
  labels     = try(each.value.labels, {})
  tags       = distinct(concat(local.tags, [for k, v in each.value.tags : "${k}:${v}"]))

  dynamic "taint" {
    for_each = try(each.value.taints, [])
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}

