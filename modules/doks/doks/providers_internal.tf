provider "helm" {
  alias = "internal_doks_charts"
  kubernetes {
    host                   = digitalocean_kubernetes_cluster.cluster.kube_config[0].host
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
    client_certificate     = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].client_certificate)
    client_key             = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].client_key)
    token                  = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  }
}