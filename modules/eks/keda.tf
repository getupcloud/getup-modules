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
    clusterName: ${module.eks.cluster_name}

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
    module.eks.fargate_profiles
  ]
}

resource "kubectl_manifest" "keda_cron" {
  for_each  = { for i in var.keda_cron_schedule : i.name => i }

  yaml_body = <<-YAML
    apiVersion: keda.sh/v1alpha1
    kind: ScaledObject
    metadata:
      name: ${each.value.name}
      namespace: ${each.value.namespace}
      annotations:
        scaledobject.keda.sh/transfer-hpa-ownership: "true"     # Optional. Use to transfer an existing HPA ownership to this ScaledObject
        # autoscaling.keda.sh/paused-replicas: "0"                # Optional. Use to pause autoscaling of objects
        # autoscaling.keda.sh/paused: "true"                      # Optional. Use to pause autoscaling of objects explicitly
    spec:
      scaleTargetRef:
        apiVersion:    ${each.value.apiVersion}
        kind:          ${each.value.kind}                       # Optional. Default: Deployment
        name:          ${each.value.name}                       # Mandatory. Must be in the same namespace as the ScaledObject
        # envSourceContainerName: {container-name}                # Optional. Default: .spec.template.spec.containers[0]
      pollingInterval:  15                                      # Optional. Default: 30 seconds
      cooldownPeriod:   300                                     # Optional. Default: 300 seconds
      #idleReplicaCount: 0                                       # Optional. Default: ignored, must be less than minReplicaCount
      minReplicaCount:  ${each.value.minReplicaCount}           # Optional. Default: 0
      maxReplicaCount:  ${each.value.maxReplicaCount}           # Optional. Default: 100
      # fallback:                                                 # Optional. Section to specify fallback options
      #   failureThreshold: 3                                     # Mandatory if fallback section is included
      #   replicas: 2                                             # Mandatory if fallback section is included
      advanced:                                                 # Optional. Section to specify advanced options
        restoreToOriginalReplicaCount: false                    # Optional. Default: false
        horizontalPodAutoscalerConfig:                          # Optional. Section to specify HPA related options
          # name: {name-of-hpa-resource}                          # Optional. Default: keda-hpa-{scaled-object-name}
          # behavior:                                             # Optional. Use to modify HPA's scaling behavior
          #   scaleDown:
          #     stabilizationWindowSeconds: 300
          #     policies:
          #     - type: Percent
          #       value: 100
          #       periodSeconds: 15
      triggers:
      ${indent(2, yamlencode([for metadata in each.value.schedules : { type : "cron", metadata : metadata }]))}
  YAML

  depends_on = [
    helm_release.keda
  ]
}


