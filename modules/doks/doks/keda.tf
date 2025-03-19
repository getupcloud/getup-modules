################################################################################
# KEDA
################################################################################

resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = var.keda_version
  namespace        = var.keda_namespace
  create_namespace = true
  wait             = true

  values = [
    <<-EOT
    clusterName: ${digitalocean_kubernetes_cluster.cluster.name}

    #priorityClassName: system-cluster-critical

    #affinity:
    #  nodeAffinity:
    #    requiredDuringSchedulingIgnoredDuringExecution:
    #      nodeSelectorTerms:
    #      - matchExpressions:
    #        - key: karpenter.sh/nodepool
    #          operator: DoesNotExist
    #        - key: eks.amazonaws.com/compute-type
    #          operator: In
    #          values:
    #          - fargate

    logging:
      operator:
        format: json
      webhooks:
        format:  json

    operator:
      replicaCount: ${var.keda_replicas}

    resources:
      metricServer:
        limits:
          cpu: 250m
          memory: 1Gi
        requests:
          cpu: 25m
          memory: 256Mi
      operator:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 25m
          memory: 256Mi
      webhooks:
        limits:
          cpu: 50m
          memory: 100Mi
        requests:
          cpu: 25m
          memory: 10Mi

    metricsServer:
      replicaCount: ${var.keda_replicas}

    webhooks:
      replicaCount: ${var.keda_replicas}
    EOT
  ]

  depends_on = [
    digitalocean_kubernetes_cluster.cluster
  ]
}
