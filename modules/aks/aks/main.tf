data "azurerm_subnet" "this" {
  count                = var.vnet_subnet == "" ? 0 : 1
  name                 = var.vnet_subnet
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "11.0.0"

  location                                                        = var.location
  resource_group_name                                             = var.resource_group_name
  aci_connector_linux_enabled                                     = var.aci_connector_linux_enabled
  aci_connector_linux_subnet_name                                 = var.aci_connector_linux_subnet_name
  admin_username                                                  = var.admin_username
  agents_availability_zones                                       = var.agents_availability_zones
  agents_count                                                    = var.agents_count
  agents_labels                                                   = var.agents_labels
  agents_max_count                                                = var.agents_max_count
  agents_max_pods                                                 = var.agents_max_pods
  agents_min_count                                                = var.agents_min_count
  agents_pool_drain_timeout_in_minutes                            = var.agents_pool_drain_timeout_in_minutes
  agents_pool_kubelet_configs                                     = var.agents_pool_kubelet_configs
  agents_pool_linux_os_configs                                    = var.agents_pool_linux_os_configs
  agents_pool_max_surge                                           = var.agents_pool_max_surge
  agents_pool_name                                                = var.agents_pool_name
  agents_pool_node_soak_duration_in_minutes                       = var.agents_pool_node_soak_duration_in_minutes
  agents_proximity_placement_group_id                             = var.agents_proximity_placement_group_id
  agents_size                                                     = var.agents_size
  agents_tags                                                     = var.agents_tags
  agents_type                                                     = var.agents_type
  api_server_authorized_ip_ranges                                 = var.api_server_authorized_ip_ranges
  attached_acr_id_map                                             = var.attached_acr_id_map
  auto_scaler_profile_balance_similar_node_groups                 = var.auto_scaler_profile_balance_similar_node_groups
  auto_scaler_profile_empty_bulk_delete_max                       = var.auto_scaler_profile_empty_bulk_delete_max
  auto_scaler_profile_expander                                    = var.auto_scaler_profile_expander
  auto_scaler_profile_max_graceful_termination_sec                = var.auto_scaler_profile_max_graceful_termination_sec
  auto_scaler_profile_max_node_provisioning_time                  = var.auto_scaler_profile_max_node_provisioning_time
  auto_scaler_profile_max_unready_nodes                           = var.auto_scaler_profile_max_unready_nodes
  auto_scaler_profile_max_unready_percentage                      = var.auto_scaler_profile_max_unready_percentage
  auto_scaler_profile_new_pod_scale_up_delay                      = var.auto_scaler_profile_new_pod_scale_up_delay
  auto_scaler_profile_scale_down_delay_after_add                  = var.auto_scaler_profile_scale_down_delay_after_add
  auto_scaler_profile_scale_down_delay_after_delete               = var.auto_scaler_profile_scale_down_delay_after_delete
  auto_scaler_profile_scale_down_delay_after_failure              = var.auto_scaler_profile_scale_down_delay_after_failure
  auto_scaler_profile_scale_down_unneeded                         = var.auto_scaler_profile_scale_down_unneeded
  auto_scaler_profile_scale_down_unready                          = var.auto_scaler_profile_scale_down_unready
  auto_scaler_profile_scale_down_utilization_threshold            = var.auto_scaler_profile_scale_down_utilization_threshold
  auto_scaler_profile_scan_interval                               = var.auto_scaler_profile_scan_interval
  auto_scaler_profile_skip_nodes_with_local_storage               = var.auto_scaler_profile_skip_nodes_with_local_storage
  auto_scaler_profile_skip_nodes_with_system_pods                 = var.auto_scaler_profile_skip_nodes_with_system_pods
  automatic_channel_upgrade                                       = var.automatic_channel_upgrade
  azure_policy_enabled                                            = var.azure_policy_enabled
  brown_field_application_gateway_for_ingress                     = var.brown_field_application_gateway_for_ingress
  client_id                                                       = var.client_id
  client_secret                                                   = var.client_secret
  cluster_log_analytics_workspace_name                            = var.cluster_log_analytics_workspace_name
  cluster_name                                                    = var.cluster_name
  cluster_name_random_suffix                                      = var.cluster_name_random_suffix
  confidential_computing                                          = var.confidential_computing
  cost_analysis_enabled                                           = var.cost_analysis_enabled
  create_monitor_data_collection_rule                             = var.create_monitor_data_collection_rule
  create_role_assignment_network_contributor                      = var.create_role_assignment_network_contributor
  create_role_assignments_for_application_gateway                 = var.create_role_assignments_for_application_gateway
  data_collection_settings                                        = var.data_collection_settings
  default_node_pool_fips_enabled                                  = var.default_node_pool_fips_enabled
  disk_encryption_set_id                                          = var.disk_encryption_set_id
  dns_prefix_private_cluster                                      = var.dns_prefix_private_cluster
  ebpf_data_plane                                                 = var.ebpf_data_plane
  auto_scaler_profile_enabled                                     = var.auto_scaler_profile_enabled
  host_encryption_enabled                                         = var.host_encryption_enabled
  node_public_ip_enabled                                          = var.node_public_ip_enabled
  green_field_application_gateway_for_ingress                     = var.green_field_application_gateway_for_ingress
  http_proxy_config                                               = var.http_proxy_config
  identity_ids                                                    = var.identity_ids
  identity_type                                                   = var.identity_type
  image_cleaner_enabled                                           = var.image_cleaner_enabled
  image_cleaner_interval_hours                                    = var.image_cleaner_interval_hours
  interval_before_cluster_update                                  = var.interval_before_cluster_update
  key_vault_secrets_provider_enabled                              = var.key_vault_secrets_provider_enabled
  kms_enabled                                                     = var.kms_enabled
  kms_key_vault_key_id                                            = var.kms_key_vault_key_id
  kms_key_vault_network_access                                    = var.kms_key_vault_network_access
  kubelet_identity                                                = var.kubelet_identity
  kubernetes_version                                              = var.kubernetes_version
  load_balancer_profile_enabled                                   = var.load_balancer_profile_enabled
  load_balancer_profile_idle_timeout_in_minutes                   = var.load_balancer_profile_idle_timeout_in_minutes
  load_balancer_profile_managed_outbound_ip_count                 = var.load_balancer_profile_managed_outbound_ip_count
  load_balancer_profile_managed_outbound_ipv6_count               = var.load_balancer_profile_managed_outbound_ipv6_count
  load_balancer_profile_outbound_ip_address_ids                   = var.load_balancer_profile_outbound_ip_address_ids
  load_balancer_profile_outbound_ip_prefix_ids                    = var.load_balancer_profile_outbound_ip_prefix_ids
  load_balancer_profile_outbound_ports_allocated                  = var.load_balancer_profile_outbound_ports_allocated
  load_balancer_sku                                               = var.load_balancer_sku
  local_account_disabled                                          = var.local_account_disabled
  log_analytics_solution                                          = var.log_analytics_solution
  log_analytics_workspace                                         = var.log_analytics_workspace
  log_analytics_workspace_allow_resource_only_permissions         = var.log_analytics_workspace_allow_resource_only_permissions
  log_analytics_workspace_cmk_for_query_forced                    = var.log_analytics_workspace_cmk_for_query_forced
  log_analytics_workspace_daily_quota_gb                          = var.log_analytics_workspace_daily_quota_gb
  log_analytics_workspace_data_collection_rule_id                 = var.log_analytics_workspace_data_collection_rule_id
  log_analytics_workspace_enabled                                 = var.log_analytics_workspace_enabled
  log_analytics_workspace_identity                                = var.log_analytics_workspace_identity
  log_analytics_workspace_immediate_data_purge_on_30_days_enabled = var.log_analytics_workspace_immediate_data_purge_on_30_days_enabled
  log_analytics_workspace_internet_ingestion_enabled              = var.log_analytics_workspace_internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled                  = var.log_analytics_workspace_internet_query_enabled
  log_analytics_workspace_local_authentication_disabled           = var.log_analytics_workspace_local_authentication_disabled
  log_analytics_workspace_reservation_capacity_in_gb_per_day      = var.log_analytics_workspace_reservation_capacity_in_gb_per_day
  log_analytics_workspace_resource_group_name                     = var.log_analytics_workspace_resource_group_name
  log_analytics_workspace_sku                                     = var.log_analytics_workspace_sku
  log_retention_in_days                                           = var.log_retention_in_days
  maintenance_window                                              = var.maintenance_window
  maintenance_window_auto_upgrade                                 = var.maintenance_window_auto_upgrade
  maintenance_window_node_os                                      = var.maintenance_window_node_os
  microsoft_defender_enabled                                      = var.microsoft_defender_enabled
  monitor_data_collection_rule_data_sources_syslog_facilities     = var.monitor_data_collection_rule_data_sources_syslog_facilities
  monitor_data_collection_rule_data_sources_syslog_levels         = var.monitor_data_collection_rule_data_sources_syslog_levels
  monitor_data_collection_rule_extensions_streams                 = var.monitor_data_collection_rule_extensions_streams
  monitor_metrics                                                 = var.monitor_metrics
  msi_auth_for_monitoring_enabled                                 = var.msi_auth_for_monitoring_enabled
  nat_gateway_profile                                             = var.nat_gateway_profile
  net_profile_dns_service_ip                                      = var.net_profile_dns_service_ip
  net_profile_outbound_type                                       = var.net_profile_outbound_type
  net_profile_pod_cidr                                            = var.net_profile_pod_cidr
  net_profile_service_cidr                                        = var.net_profile_service_cidr
  network_contributor_role_assigned_subnet_ids                    = var.network_contributor_role_assigned_subnet_ids
  network_plugin                                                  = var.network_plugin
  network_plugin_mode                                             = var.network_plugin_mode
  network_policy                                                  = var.network_policy
  node_network_profile                                            = var.node_network_profile
  node_os_channel_upgrade                                         = var.node_os_channel_upgrade
  node_pools                                                      = {}
  node_resource_group                                             = var.node_resource_group
  oidc_issuer_enabled                                             = var.oidc_issuer_enabled
  oms_agent_enabled                                               = var.oms_agent_enabled
  only_critical_addons_enabled                                    = var.only_critical_addons_enabled
  open_service_mesh_enabled                                       = var.open_service_mesh_enabled
  orchestrator_version                                            = var.orchestrator_version
  os_disk_size_gb                                                 = var.os_disk_size_gb
  os_disk_type                                                    = var.os_disk_type
  os_sku                                                          = var.os_sku
  pod_subnet                                                      = var.pod_subnet
  prefix                                                          = var.prefix
  private_cluster_enabled                                         = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled                             = var.private_cluster_public_fqdn_enabled
  private_dns_zone_id                                             = var.private_dns_zone_id
  public_ssh_key                                                  = var.public_ssh_key
  rbac_aad_admin_group_object_ids                                 = var.rbac_aad_admin_group_object_ids
  rbac_aad_azure_rbac_enabled                                     = var.rbac_aad_azure_rbac_enabled
  rbac_aad_tenant_id                                              = var.rbac_aad_tenant_id
  role_based_access_control_enabled                               = var.role_based_access_control_enabled
  run_command_enabled                                             = var.run_command_enabled
  scale_down_mode                                                 = var.scale_down_mode
  secret_rotation_enabled                                         = var.secret_rotation_enabled
  secret_rotation_interval                                        = var.secret_rotation_interval
  service_mesh_profile                                            = var.service_mesh_profile
  sku_tier                                                        = var.sku_tier
  snapshot_id                                                     = var.snapshot_id
  storage_profile_blob_driver_enabled                             = var.storage_profile_blob_driver_enabled
  storage_profile_disk_driver_enabled                             = var.storage_profile_disk_driver_enabled
  storage_profile_enabled                                         = var.storage_profile_enabled
  storage_profile_file_driver_enabled                             = var.storage_profile_file_driver_enabled
  storage_profile_snapshot_controller_enabled                     = var.storage_profile_snapshot_controller_enabled
  support_plan                                                    = var.support_plan
  tags                                                            = var.tags
  temporary_name_for_rotation                                     = var.temporary_name_for_rotation
  ultra_ssd_enabled                                               = var.ultra_ssd_enabled
  vnet_subnet                                                     = var.vnet_subnet != "" ? data.azurerm_subnet.this[0] : null
  web_app_routing                                                 = var.web_app_routing
  workload_autoscaler_profile                                     = var.workload_autoscaler_profile
  workload_identity_enabled                                       = var.workload_identity_enabled
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  kubernetes_cluster_id         = module.aks.aks_id
  name                          = each.key
  auto_scaling_enabled          = each.value.auto_scaling_enabled
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  eviction_policy               = each.value.eviction_policy
  fips_enabled                  = each.value.fips_enabled
  gpu_instance                  = each.value.gpu_instance
  gpu_driver                    = each.value.gpu_driver
  host_encryption_enabled       = each.value.host_encryption_enabled
  host_group_id                 = each.value.host_group_id
  kubelet_disk_type             = each.value.kubelet_disk_type
  max_count                     = each.value.max_count
  max_pods                      = each.value.max_pods
  min_count                     = each.value.min_count
  mode                          = each.value.mode
  node_count                    = each.value.node_count
  node_labels                   = each.value.node_labels
  node_public_ip_enabled        = each.value.node_public_ip_enabled
  node_public_ip_prefix_id      = each.value.node_public_ip_prefix_id
  node_taints                   = each.value.node_taints
  orchestrator_version          = each.value.orchestrator_version
  os_disk_size_gb               = each.value.os_disk_size_gb
  os_disk_type                  = each.value.os_disk_type
  os_sku                        = each.value.os_sku
  os_type                       = each.value.os_type
  pod_subnet_id                 = try(each.value.pod_subnet.id, null)
  priority                      = each.value.priority
  proximity_placement_group_id  = each.value.proximity_placement_group_id
  scale_down_mode               = each.value.scale_down_mode
  snapshot_id                   = each.value.snapshot_id
  spot_max_price                = each.value.spot_max_price
  tags                          = each.value.tags
  temporary_name_for_rotation   = each.value.temporary_name_for_rotation
  ultra_ssd_enabled             = each.value.ultra_ssd_enabled
  vm_size                       = each.value.vm_size
  vnet_subnet_id                = try(each.value.vnet_subnet.id, data.azurerm_subnet.this[0].id)
  workload_runtime              = each.value.workload_runtime
  zones                         = each.value.zones

  dynamic "kubelet_config" {
    for_each = each.value.kubelet_config == null ? [] : ["kubelet_config"]

    content {
      allowed_unsafe_sysctls    = each.value.kubelet_config.allowed_unsafe_sysctls
      container_log_max_line    = each.value.kubelet_config.container_log_max_files
      container_log_max_size_mb = each.value.kubelet_config.container_log_max_size_mb
      cpu_cfs_quota_enabled     = each.value.kubelet_config.cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = each.value.kubelet_config.cpu_cfs_quota_period
      cpu_manager_policy        = each.value.kubelet_config.cpu_manager_policy
      image_gc_high_threshold   = each.value.kubelet_config.image_gc_high_threshold
      image_gc_low_threshold    = each.value.kubelet_config.image_gc_low_threshold
      pod_max_pid               = each.value.kubelet_config.pod_max_pid
      topology_manager_policy   = each.value.kubelet_config.topology_manager_policy
    }
  }
  dynamic "linux_os_config" {
    for_each = each.value.linux_os_config == null ? [] : ["linux_os_config"]

    content {
      swap_file_size_mb             = each.value.linux_os_config.swap_file_size_mb
      transparent_huge_page_defrag  = each.value.linux_os_config.transparent_huge_page_defrag
      transparent_huge_page_enabled = each.value.linux_os_config.transparent_huge_page_enabled

      dynamic "sysctl_config" {
        for_each = each.value.linux_os_config.sysctl_config == null ? [] : ["sysctl_config"]

        content {
          fs_aio_max_nr                      = each.value.linux_os_config.sysctl_config.fs_aio_max_nr
          fs_file_max                        = each.value.linux_os_config.sysctl_config.fs_file_max
          fs_inotify_max_user_watches        = each.value.linux_os_config.sysctl_config.fs_inotify_max_user_watches
          fs_nr_open                         = each.value.linux_os_config.sysctl_config.fs_nr_open
          kernel_threads_max                 = each.value.linux_os_config.sysctl_config.kernel_threads_max
          net_core_netdev_max_backlog        = each.value.linux_os_config.sysctl_config.net_core_netdev_max_backlog
          net_core_optmem_max                = each.value.linux_os_config.sysctl_config.net_core_optmem_max
          net_core_rmem_default              = each.value.linux_os_config.sysctl_config.net_core_rmem_default
          net_core_rmem_max                  = each.value.linux_os_config.sysctl_config.net_core_rmem_max
          net_core_somaxconn                 = each.value.linux_os_config.sysctl_config.net_core_somaxconn
          net_core_wmem_default              = each.value.linux_os_config.sysctl_config.net_core_wmem_default
          net_core_wmem_max                  = each.value.linux_os_config.sysctl_config.net_core_wmem_max
          net_ipv4_ip_local_port_range_max   = each.value.linux_os_config.sysctl_config.net_ipv4_ip_local_port_range_max
          net_ipv4_ip_local_port_range_min   = each.value.linux_os_config.sysctl_config.net_ipv4_ip_local_port_range_min
          net_ipv4_neigh_default_gc_thresh1  = each.value.linux_os_config.sysctl_config.net_ipv4_neigh_default_gc_thresh1
          net_ipv4_neigh_default_gc_thresh2  = each.value.linux_os_config.sysctl_config.net_ipv4_neigh_default_gc_thresh2
          net_ipv4_neigh_default_gc_thresh3  = each.value.linux_os_config.sysctl_config.net_ipv4_neigh_default_gc_thresh3
          net_ipv4_tcp_fin_timeout           = each.value.linux_os_config.sysctl_config.net_ipv4_tcp_fin_timeout
          net_ipv4_tcp_keepalive_intvl       = each.value.linux_os_config.sysctl_config.net_ipv4_tcp_keepalive_intvl
          net_ipv4_tcp_keepalive_probes      = each.value.linux_os_config.sysctl_config.net_ipv4_tcp_keepalive_probes
          net_ipv4_tcp_keepalive_time        = each.value.linux_os_config.sysctl_config.net_ipv4_tcp_keepalive_time
          net_ipv4_tcp_max_syn_backlog       = each.value.linux_os_config.sysctl_config.net_ipv4_tcp_max_syn_backlog
          net_ipv4_tcp_max_tw_buckets        = each.value.linux_os_config.sysctl_config.net_ipv4_tcp_max_tw_buckets
          net_ipv4_tcp_tw_reuse              = each.value.linux_os_config.sysctl_config.net_ipv4_tcp_tw_reuse
          net_netfilter_nf_conntrack_buckets = each.value.linux_os_config.sysctl_config.net_netfilter_nf_conntrack_buckets
          net_netfilter_nf_conntrack_max     = each.value.linux_os_config.sysctl_config.net_netfilter_nf_conntrack_max
          vm_max_map_count                   = each.value.linux_os_config.sysctl_config.vm_max_map_count
          vm_swappiness                      = each.value.linux_os_config.sysctl_config.vm_swappiness
          vm_vfs_cache_pressure              = each.value.linux_os_config.sysctl_config.vm_vfs_cache_pressure
        }
      }
    }
  }
  dynamic "node_network_profile" {
    for_each = each.value.node_network_profile == null ? [] : ["node_network_profile"]

    content {
      application_security_group_ids = each.value.node_network_profile.application_security_group_ids
      node_public_ip_tags            = each.value.node_network_profile.node_public_ip_tags

      dynamic "allowed_host_ports" {
        for_each = each.value.node_network_profile.allowed_host_ports == null ? [] : each.value.node_network_profile.allowed_host_ports

        content {
          port_end   = allowed_host_ports.value.port_end
          port_start = allowed_host_ports.value.port_start
          protocol   = allowed_host_ports.value.protocol
        }
      }
    }
  }
  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings == null ? [] : ["upgrade_settings"]

    content {
      max_surge                     = each.value.upgrade_settings.max_surge
      drain_timeout_in_minutes      = each.value.upgrade_settings.drain_timeout_in_minutes
      node_soak_duration_in_minutes = each.value.upgrade_settings.node_soak_duration_in_minutes
    }
  }
  dynamic "windows_profile" {
    for_each = each.value.windows_profile == null ? [] : ["windows_profile"]

    content {
      outbound_nat_enabled = each.value.windows_profile.outbound_nat_enabled
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name
    ]

    precondition {
      condition     = can(regex("[a-z0-9]{1,8}", each.key))
      error_message = "A Node Pools name must consist of alphanumeric characters and have a maximum lenght of 8 characters (4 random chars added)"
    }
    precondition {
      condition     = var.network_plugin_mode != "overlay" || !can(regex("^Standard_DC[0-9]+s?_v2$", each.value.vm_size))
      error_message = "With with Azure CNI Overlay you can't use DCsv2-series virtual machines in node pools. "
    }
    precondition {
      condition     = var.agents_type == "VirtualMachineScaleSets"
      error_message = "Multiple Node Pools are only supported when the Kubernetes Cluster is using Virtual Machine Scale Sets."
    }
  }
}