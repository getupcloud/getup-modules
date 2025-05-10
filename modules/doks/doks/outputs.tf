################################################################################
# Cluster
################################################################################

output "doks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = digitalocean_kubernetes_cluster.cluster.name
}

output "doks_cluster_id" {
  description = "A unique ID that can be used to identify and reference a Kubernetes cluster."
  value       = digitalocean_kubernetes_cluster.cluster.id
}

output "doks_region" {
  description = "DigitalOcean Region."
  value       = var.region
}

output "doks_cluster_endpoint" {
  description = "The base URL of the API server on the Kubernetes master node."
  value       = digitalocean_kubernetes_cluster.cluster.endpoint
}

output "doks_kubeconfig" {
  description = "A representation of the Kubernetes cluster's kubeconfig."
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0]
  sensitive   = true
}

output "doks_node_pool" {
  description = "Cluster's default node pool attributes."
  value       = digitalocean_kubernetes_cluster.cluster.node_pool
}

output "doks_cluster_urn" {
  description = "The uniform resource name (URN) for the Kubernetes cluster."
  value       = digitalocean_kubernetes_cluster.cluster.urn
}

output "doks_ipv4_address" {
  description = "The public IPv4 address of the Kubernetes master node. This will not be set if high availability is configured on the cluster."
  value       = digitalocean_kubernetes_cluster.cluster.ipv4_address
}

output "doks_cluster_vpc_uuid" {
  description = "UUID of the cluster VPC"
  value       = local.vpc_uuid
}

#output "doks_default_storage_class_name" {
#  description = "Default StorageClass name"
#  value       = kubernetes_storage_class_v1.gp3.metadata[0].name
#}
