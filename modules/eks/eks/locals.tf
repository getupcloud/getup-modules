locals {
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  region          = var.aws_region

  arn_is_iam_user          = !strcontains(data.aws_caller_identity.current.arn, ":assumed-role/")
  vpc_id                   = var.vpc_id != "" ? var.vpc_id : module.vpc[0].vpc_id
  subnet_ids               = var.vpc_id != "" ? var.private_subnet_ids : module.vpc[0].private_subnets
  control_plane_subnet_ids = var.vpc_id != "" ? var.control_plane_subnet_ids : module.vpc[0].intra_subnets
  aws_auth_user_arns       = concat(local.arn_is_iam_user ? [data.aws_caller_identity.current.arn] : [], var.aws_auth_user_arns)
  kms_key_administrators   = concat(local.arn_is_iam_user ? [data.aws_caller_identity.current.arn] : [], var.kms_key_administrators)

  fargate_namespaces = [for p in var.fargate_profiles : p.namespace]
  fargate = {
    enabled     = length(var.fargate_profiles) > 0
    kube_system = contains(local.fargate_namespaces, "kube-system")
    karpenter   = contains(local.fargate_namespaces, var.karpenter_namespace)
    keda        = contains(local.fargate_namespaces, var.keda_namespace)
  }

  spot_portion            = ceil(var.karpenter_node_group_spot_ratio * 10)
  spot_limits_memory      = ceil(var.karpenter_node_group_spot_ratio * var.karpenter_cluster_limits_memory_gb)
  spot_limits_cpu         = ceil(var.karpenter_node_group_spot_ratio * var.karpenter_cluster_limits_cpu)
  on_demand_portion       = 10 - local.spot_portion
  on_demand_limits_memory = var.karpenter_cluster_limits_memory_gb - local.spot_limits_memory
  on_demand_limits_cpu    = var.karpenter_cluster_limits_cpu - local.spot_limits_cpu

  vpc_cidr = var.vpc_cidr
  azs      = var.vpc_zones

  tags = var.tags

  cluster_security_group_additional_rules = {
    current-vpc = {
      description = "VPC to cluster API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.eks.cidr_block]
    }
  }

  #warn_instances = [
  #  for cat in var.karpenter_node_pool_instance_category : [
  #    for id in ["c1," "cc1," "cc2," "cg1," "cg2," "cr1," "g1," "g2," "hi1," "hs1," "m1," "m2," "m3," "t1"] : [
  #      id == cat ? warn() : id
  #    ]
  #  ]
  #]
}

