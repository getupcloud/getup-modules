# File auto-generated by command: ./bin/make-example main doks doks v2.1.5

module "doks" {
  source = "git@github.com:getupcloud/getup-modules//modules/doks/doks?ref=v2.1.5"

  cluster_name         = var.cluster_name
  kubernetes_version   = var.kubernetes_version
  region               = var.region
  control_plane_ha     = var.control_plane_ha
  auto_upgrade         = var.auto_upgrade
  maintenance_policy   = var.maintenance_policy
  surge_upgrade        = var.surge_upgrade
  tags                 = var.tags
  registry_integration = var.registry_integration
  vpc_uuid             = var.vpc_uuid
  vpc_name             = var.vpc_name
  vpc_ip_range         = var.vpc_ip_range
  vpc_description      = var.vpc_description
  default_node_pool    = var.default_node_pool
  node_pools           = var.node_pools
  keda_namespace       = var.keda_namespace
  keda_version         = var.keda_version
  keda_replicas        = var.keda_replicas
  baloon_chart_version = var.baloon_chart_version
  baloon_namespace     = var.baloon_namespace
  baloon_replicas      = var.baloon_replicas
  baloon_cpu           = var.baloon_cpu
  baloon_memory        = var.baloon_memory
}
