provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

data "aws_caller_identity" "current" {}

data "aws_ecrpublic_authorization_token" "token" {
  # Temporary workaround due to AWS Public ECR only supporting us-east-1
  # https://github.com/hashicorp/terraform-provider-aws/issues/28281
  provider = aws.us-east-1
}

data "aws_vpc" "eks" {
  id = local.vpc_id
}

# https://karpenter.sh/v0.34/getting-started/getting-started-with-karpenter/
#
# aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
# If the role has already been successfully created, you will see:
# An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.

resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.10.0"

  cluster_name                         = local.cluster_name
  cluster_version                      = local.cluster_version
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access ? var.cluster_endpoint_public_access_cidrs : null
  create_iam_role                      = var.iam_role_arn == null
  iam_role_arn                         = var.iam_role_arn
  iam_role_name                        = var.eks_iam_role_name
  iam_role_use_name_prefix             = var.iam_role_use_name_prefix

  enable_cluster_creator_admin_permissions = true

  cluster_enabled_log_types   = []
  create_cloudwatch_log_group = false

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn    = module.ebs_csi_driver_irsa.iam_role_arn
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values        = jsonencode(var.kube_proxy)
    }
    vpc-cni = {
      before_compute              = true
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values = var.vpc_cni_enable_prefix_delegation ? jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      }) : null
    }
    coredns = {
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values = local.fargate.kube_system ? jsonencode({
        computeType = "Fargate"
        # Ensure that we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      }) : null
    }
    eks-pod-identity-agent = {}
  }

  vpc_id                   = local.vpc_id
  subnet_ids               = local.subnet_ids
  control_plane_subnet_ids = local.control_plane_subnet_ids

  create_cluster_security_group = var.create_cluster_security_group
  cluster_security_group_id     = var.cluster_security_group_id
  cluster_security_group_name   = var.cluster_security_group_name
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#i-received-an-error-expect-exactly-one-securitygroup-tagged-with-kubernetesioclustername-
  create_node_security_group              = false
  cluster_security_group_additional_rules = local.cluster_security_group_additional_rules

  cluster_encryption_config = var.cluster_encryption_config

  kms_key_administrators = local.kms_key_administrators

  fargate_profiles = {
    default = {
      name      = "default"
      selectors = var.fargate_profiles
    }
  }

  #fargate_profiles = {
  #  for p in var.fargate_profiles : p.namespace => {
  #      name: p.namespace
  #      selectors: [p]
  #  }
  #}

  eks_managed_node_groups = {
    fallback = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      ami_type       = var.fallback_node_group_ami_type
      platform       = var.fallback_node_group_platform
      instance_types = var.fallback_node_group_instance_types
      min_size       = var.fallback_node_group_desired_size
      max_size       = max(var.fallback_node_group_desired_size, 1)
      desired_size   = var.fallback_node_group_desired_size
      disk_size      = var.fallback_node_group_disk_size
      #      disk_type      = var.fallback_node_group_disk_type
    }
  }

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cluster_name
  })
}

module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.10.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = concat(
    [
      for arn in var.aws_auth_role_arns : {
        rolearn  = arn
        username = split("/", arn)[1]
        groups   = var.aws_auth_role_groups
      }
    ],
    var.aws_auth_roles
  )

  aws_auth_users = concat(
    [
      for arn in local.aws_auth_user_arns : {
        userarn  = arn
        username = strcontains(arn, "/") ? split("/", arn)[1] : split(":", arn)[5]
        groups   = var.aws_auth_user_groups
      }
    ],
    var.aws_auth_users
  )

  aws_auth_accounts = var.aws_auth_accounts
}

# https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/patterns/stateful/main.tf
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

# https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/patterns/stateful/main.tf
resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  # This is true because the resources was already created by the ebs-csi-driver addon
  force = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    # Modify annotations to remove gp2 as default storage class still retain the class
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [
    module.eks.cluster_name
  ]
}

# https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/patterns/stateful/main.tf
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      # Annotation to set gp3 as default storage class
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    encrypted = true
    fsType    = "ext4"
    type      = "gp3"
  }

  depends_on = [
    module.eks.cluster_name
  ]
}

################################################################################
# Karpenter
################################################################################

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
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = var.karpenter_version
  namespace           = module.karpenter.namespace
  create_namespace    = true
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

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

################################################################################
# Baloon
################################################################################

resource "helm_release" "baloon" {
  namespace        = var.baloon_namespace
  create_namespace = true

  name       = "baloon"
  repository = "https://charts.getup.io/getupcloud/"
  chart      = "baloon"
  version    = var.baloon_chart_version

  values = [
    <<-EOT
    replicas: ${var.baloon_replicas}

    resources:
      cpu: ${var.baloon_cpu}
      memory: ${var.baloon_memory}
    EOT
  ]

  depends_on = [
    helm_release.karpenter
  ]
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  count   = var.vpc_id == "" ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name != "" ? var.vpc_name : local.cluster_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.cluster_name
  }

  tags = local.tags
}
