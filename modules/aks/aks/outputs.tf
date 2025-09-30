output "node_resource_group" {
  value       = module.aks.node_resource_group
  description = "The name of the Resource Group where the Kubernetes Nodes should exist."
}

output "location" {
  value       = module.aks.location
  description = "The location where the Managed Kubernetes Cluster is created."
}

output "aks_id" {
  value       = module.aks.aks_id
  description = "The Kubernetes Managed Cluster ID."
}

output "http_application_routing_zone_name" {
  value       = module.aks.http_application_routing_zone_name
  description = "The Zone Name of the HTTP Application Routing."
}

output "kubelet_identity" {
  value       = module.aks.kubelet_identity
  description = "The Client, Object and User Assigned Identity IDs of the Managed Identity to be assigned to the Kubelets."
}

output "kube_admin_config_raw" {
  value       = module.aks.kube_admin_config_raw
  description = "Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
}

output "kube_config_raw" {
  value       = module.aks.kube_config_raw
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools."
}

output "generated_cluster_public_ssh_key" {
  value       = module.aks.generated_cluster_public_ssh_key
  description = "The cluster will use this generated public key as ssh key when `var.public_ssh_key` is empty or null. The fingerprint of the public key data in OpenSSH MD5 hash format, e.g. `aa:bb:cc:....` Only available if the selected private key format is compatible, similarly to `public_key_openssh` and the [ECDSA P224 limitations](https://registry.terraform.io/providers/hashicorp/tls/latest/docs#limitations)."
}

output "azurerm_log_analytics_workspace_id" {
  value       = module.aks.azurerm_log_analytics_workspace_id
  description = "The Log Analytics Workspace ID."
}

output "admin_client_certificate" {
  value       = module.aks.admin_client_certificate
  description = "The client certificate for the admin endpoint."
  sensitive   = true
}

output "admin_client_key" {
  value       = module.aks.admin_client_key
  description = "The client key for the admin endpoint."
  sensitive   = true
}

output "admin_cluster_ca_certificate" {
  value       = module.aks.admin_cluster_ca_certificate
  description = "The cluster CA certificate for the admin endpoint."
  sensitive   = true
}

output "admin_host" {
  value       = module.aks.admin_host
  description = "The host name of the admin endpoint."
}