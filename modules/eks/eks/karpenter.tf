################################################################################
# Karpenter
################################################################################
#
# https://karpenter.sh/v0.34/getting-started/getting-started-with-karpenter/
#
# aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
# If the role has already been successfully created, you will see:
# An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.
#
# This can't be shared among different clusters as it's a account-level resource
#
#resource "aws_iam_service_linked_role" "spot" {
#  aws_service_name = "spot.amazonaws.com"
#
#  lifecycle {
#    replace_triggered_by = [null_resource.once]
#    ignore_changes       = [aws_service_name]
#  }
#}
#
#resource "null_resource" "once" {
#  triggers = {
#    once = true
#  }
#}


module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.36"

  cluster_name        = module.eks.cluster_name
  enable_irsa         = true
  enable_pod_identity = false
  #create_pod_identity_association = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn
  namespace              = var.karpenter_namespace
  service_account        = "karpenter"

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

resource "helm_release" "karpenter-crd" {
  name             = "karpenter-crd"
  repository       = "https://charts.getup.io/karpenter"
  chart            = "karpenter-crd"
  version          = var.karpenter_version
  namespace        = module.karpenter.namespace
  create_namespace = true
  wait             = true
}

# TODO: parametrize resources
resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "https://charts.getup.io/karpenter"
  chart            = "karpenter"
  version          = var.karpenter_version
  namespace        = module.karpenter.namespace
  create_namespace = true
  wait             = true

  values = [
    <<-EOT
    serviceAccount:
      create: true
      name: ${module.karpenter.service_account}
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}

    replicas: ${var.karpenter_replicas}

    controller:
      resources:
        requests:
          cpu: 500m
          memory: 768Mi
        limits:
          cpu: 500m
          memory: 768Mi

    logLevel: debug

    settings:
      batchMaxDuration: 10s
      batchIdleDuration: 2s
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      eksControlPlane: true
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]

  depends_on = [
    module.eks.fargate_profiles,
    helm_release.karpenter-crd
  ]

  #lifecycle {
  #  ignore_changes = [
  #    repository_password
  #  ]
  #}
}

resource "kubectl_manifest" "karpenter_node_class" {
  for_each = toset(var.karpenter_enabled ? ["default"] : [])

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: ${var.karpenter_node_class_ami_family}
      amiSelectorTerms:
      - alias: ${lower(var.karpenter_node_class_ami_family)}@1.39.1
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        ${indent(4, yamlencode(merge(var.tags, { "karpenter.sh/discovery" : module.eks.cluster_name })))}

      %{if var.karpenter_node_class_ami_family == "Bottlerocket"}
      blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 4Gi
          volumeType: gp3
      - deviceName: /dev/xvdb
        ebs:
          volumeSize: 60Gi
          volumeType: gp3
      %{endif}
      %{if var.karpenter_node_class_ami_family == "AL2" || var.karpenter_node_class_ami_family == "AL2023"}
      blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 60Gi
          volumeType: gp3
      %{endif}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_pool_infra" {
  for_each = toset(var.karpenter_enabled ? ["infra"] : [])

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: infra
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default
          requirements:
            - key: role
              operator: In
              values:
              - infra
            - key: karpenter.sh/capacity-type
              operator: In
              values:
              - on-demand
            - key: "kubernetes.io/arch"
              operator: In
              values:
              - arm64
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values:
              - c
              - m
              - r
              - t
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values:
              - "8"
              - "16"
              - "32"
            - key: "karpenter.k8s.aws/instance-memory"
              operator: In
              values:
              - "${ceil(16 * 1024)}"
              - "${ceil(32 * 1024)}"
              - "${ceil(64 * 1024)}"
          taints:
            ${indent(8, yamlencode(var.karpenter_node_pool_taints.infra))}
      limits:
        cpu: ${local.on_demand_limits_cpu}
        memory: "${local.on_demand_limits_memory}Gi"
      disruption:
        consolidationPolicy: WhenEmptyOrUnderutilized
        consolidateAfter: 1h
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

resource "kubectl_manifest" "karpenter_node_pool_on_demand" {
  for_each = toset(var.karpenter_enabled ? ["on-demand"] : [])

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: on-demand
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default
          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]
            - key: "kubernetes.io/arch"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_arch))}
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_category))}
            %{if length(var.karpenter_node_pool_instance_cpu) > 0}
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_cpu))}
            %{endif}
            %{if length(var.karpenter_node_pool_instance_memory_gb) > 0}
            - key: "karpenter.k8s.aws/instance-memory"
              operator: In
              values:
              ${indent(10, yamlencode([for m in var.karpenter_node_pool_instance_memory_gb : tostring(ceil(m * 1024))]))}
            %{endif}
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
            %{if local.on_demand_portion > 0}
            - key: capacity-spread
              operator: In
              values:
              ${indent(10, yamlencode([for i in range(local.on_demand_portion) : "ondemand-${i}"]))}
            %{endif}
          taints:
            ${indent(8, yamlencode(var.karpenter_node_pool_taints.on-demand))}
      limits:
        cpu: ${local.on_demand_limits_cpu}
        memory: "${local.on_demand_limits_memory}Gi"
      disruption:
        consolidationPolicy: WhenEmptyOrUnderutilized
        consolidateAfter: 1h
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

resource "kubectl_manifest" "karpenter_node_pool_spot" {
  for_each = toset(var.karpenter_enabled ? ["spot"] : [])

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: spot
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default 
          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["spot"]
            - key: "kubernetes.io/arch"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_arch))}
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_category))}
            %{if length(var.karpenter_node_pool_instance_cpu) > 0}
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_cpu))}
            %{endif}
            %{if length(var.karpenter_node_pool_instance_memory_gb) > 0}
            - key: "karpenter.k8s.aws/instance-memory"
              operator: In
              values:
              ${indent(10, yamlencode([for m in var.karpenter_node_pool_instance_memory_gb : tostring(m * 1024)]))}
            %{endif}
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
            %{if local.spot_portion > 0}
            - key: capacity-spread
              operator: In
              values:
              ${indent(10, yamlencode([for i in range(local.spot_portion) : "spot-${i}"]))}
            %{endif}
          taints:
            ${indent(8, yamlencode(var.karpenter_node_pool_taints.spot))}
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: karpenter.sh/nodepool
              operator: DoesNotExist
    #        - key: eks.amazonaws.com/compute-type
    #          operator: In
    #          values:
    #          - fargate
      limits:
        cpu: ${local.spot_limits_cpu}
        memory: "${local.spot_limits_memory}Gi"
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}
