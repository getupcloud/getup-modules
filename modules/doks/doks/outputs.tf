################################################################################
# Cluster
################################################################################

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = digitalocean_kubernetes_cluster.cluster.name
}

output "cluster_id" {
  description = "A unique ID that can be used to identify and reference a Kubernetes cluster."
  value       = digitalocean_kubernetes_cluster.cluster.id
}

output "region" {
  description = "DigitalOcean Region."
  value       = var.region
}

output "cluster_endpoint" {
  description = "The base URL of the API server on the Kubernetes master node."
  value       = digitalocean_kubernetes_cluster.cluster.endpoint
}

output "kubeconfig" {
  description = "A representation of the Kubernetes cluster's kubeconfig."
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0]
}

output "node_pool" {
  description = "Cluster's default node pool attributes."
  value       = digitalocean_kubernetes_cluster.cluster.node_pool
}

output "cluster_urn" {
  description = "The uniform resource name (URN) for the Kubernetes cluster."
  value       = digitalocean_kubernetes_cluster.cluster.urn
}

output "ipv4_address" {
  description = "The public IPv4 address of the Kubernetes master node. This will not be set if high availability is configured on the cluster."
  value       = digitalocean_kubernetes_cluster.cluster.ipv4_address
}

output "cluster_vpc_uuid" {
  description = "UUID of the cluster VPC"
  value       = local.vpc_uuid
}

#output "default_storage_class_name" {
#  description = "Default StorageClass name"
#  value       = kubernetes_storage_class_v1.gp3.metadata[0].name
#}
