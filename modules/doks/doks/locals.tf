locals {
  vpc_create = var.vpc_uuid == "" && var.vpc_name != ""
  vpc_uuid   = local.vpc_create ? digitalocean_vpc.vpc[0].id : var.vpc_uuid
  tags       = [for k, v in var.tags : "${k}:${v}"]

  node_selector = merge(
    { default : try(var.default_node_pool.labels) },
    { for nodepool in var.node_pools : nodepool.name => try(nodepool.labels, {}) }
  )

  tolerations = merge(
    {
      default : [for taint in try(var.default_node_pool.taints, []) : {
        key : try(taint.key, null),
        value : try(taint.value, null),
        effect : try(taint.effect, null),
        operator : try(taint.value, null) == null ? "Exists" : "Equal"
      }]
      }, {
      for nodepool in var.node_pools : nodepool.name => [
        for taint in try(nodepool.taints, []) : {
          key : try(taint.key, null),
          value : try(taint.value, null),
          effect : try(taint.effect, null),
          operator : try(taint.value, null) == null ? "Exists" : "Equal"
        }
      ]
    }
  )
}
