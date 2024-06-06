data "aws_caller_identity" "current" {}

data "aws_vpc" "eks" {
  id = local.vpc_id
}

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
      min_size       = 0
      max_size       = var.fallback_node_group_desired_size
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

  manage_aws_auth_configmap = false

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

  depends_on = [
    module.eks.cluster_endpoint
  ]
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
    module.eks.cluster_endpoint
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
    module.eks.cluster_endpoint
  ]
}

