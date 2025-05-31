################################################################################
# Baloon
################################################################################

resource "helm_release" "baloon" {
  provider = helm.internal_doks_charts
  namespace        = var.baloon_namespace
  create_namespace = true

  name       = "baloon"
  repository = "https://charts.getup.io/getupcloud/"
  chart      = "baloon"
  version    = var.baloon_chart_version
  wait       = false

  values = [
    <<-EOT
    replicas: ${var.baloon_replicas}

    resources:
      cpu: ${var.baloon_cpu}
      memory: ${var.baloon_memory}
    EOT
  ]

  depends_on = [
    digitalocean_kubernetes_cluster.cluster
  ]
}
