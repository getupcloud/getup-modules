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
  version = "~> 20.10.0"

  cluster_name                    = module.eks.cluster_name
  enable_pod_identity             = true
  create_pod_identity_association = true
  namespace                       = var.karpenter_namespace
  service_account                 = "karpenter"

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

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
    replicas: ${var.karpenter_replicas}
    serviceAccount:
      create: true
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueueName: ${module.karpenter.queue_name}
      settings.featureGates.drift: true
      controller.resources.requests.cpu: "250m"
      controller.resources.requests.memory: "256Mi"
      controller.resources.limits.cpu: "250m"
      controller.resources.limits.memory: "256Mi"
    EOT
  ]

  depends_on = [
    module.eks.fargate_profiles
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
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: ${var.karpenter_node_class_ami_family}
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
    %{ if var.karpenter_node_class_ami_family == "Bottlerocket" }
    blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 4Gi
        volumeType: gp3
    - deviceName: /dev/xvdb
      ebs:
        volumeSize: 50Gi
        volumeType: gp3
    %{ endif }
    %{ if var.karpenter_node_class_ami_family == "AL2" }
    blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 50Gi
        volumeType: gp3
    %{ endif }
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_pool_on_demand" {
  for_each = toset(var.karpenter_enabled ? ["on-demand"] : [])

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: on-demand
    spec:
      template:
        spec:
          nodeClassRef:
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
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_cpu))}
            - key: "karpenter.k8s.aws/instance-memory"
              operator: In
              values:
              ${indent(10, yamlencode([for m in var.karpenter_node_pool_instance_memory_gb : tostring(m * 1024)]))}
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
            - key: capacity-spread
              operator: In
              values:
              ${indent(10, yamlencode([for i in range(local.on_demand_portion) : "ondemand-${i}"]))}
      limits:
        cpu: ${local.on_demand_limits_cpu}
        memory: "${local.on_demand_limits_memory}Gi"
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

resource "kubectl_manifest" "karpenter_node_pool_spot" {
  for_each = toset(var.karpenter_enabled ? ["spot"] : [])

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: spot
    spec:
      template:
        spec:
          nodeClassRef:
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
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values:
              ${indent(10, yamlencode(var.karpenter_node_pool_instance_cpu))}
            - key: "karpenter.k8s.aws/instance-memory"
              operator: In
              values:
              ${indent(10, yamlencode([for m in var.karpenter_node_pool_instance_memory_gb : tostring(m * 1024)]))}
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
            - key: capacity-spread
              operator: In
              values:
              ${indent(10, yamlencode([for i in range(local.spot_portion) : "spot-${i}"]))}
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


