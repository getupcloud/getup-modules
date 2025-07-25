#### Cluster ####
#################

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes controlplane version."
  type        = string
  default     = "1.32"
}

variable "aws_region" {
  description = "AWS Region."
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID to restrict resources. This is a safety measurement to avoid creating/destroying in the wrong account."
  type        = string
}

variable "cluster_enabled_log_types" {
  description = "(Optional) List of the desired control plane logging to enable."
  type        = list(string)
  default     = ["audit"]
}

variable "cluster_log_retention_days" {
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 3
}

variable "ebs_reclaim_policy" {
  description = "(Optional) Reclaim policy for StorageClasses gp2 and gp3."
  type        = string
  default     = "Retain"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = any
  default = {
    "managed-by" : "terraform"
  }
}

#### Encryption ####
####################

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}`"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

#### Network ####
#################

## Use an existing VPC

variable "vpc_id" {
  description = "VPC ID of an existing VPC. Set to disable VPC creation."
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs of an existing VPC."
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs of an existing VPC."
  type        = list(string)
  default     = []
}

variable "control_plane_subnet_ids" {
  description = "Control Plane Subnet IDs of an existing VPC."
  type        = list(string)
  default     = []
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = "10.100.0.0/16"
}

## Create a new VPC

variable "vpc_name" {
  description = "VPC name to create new VPC. Defaults to cluster name."
  type        = string
  default     = ""
}

variable "vpc_zones" {
  description = "AZ names to create the subnets. Use 'aws ec2 describe-availability-zones --region <region> | jq .AvailabilityZones[].ZoneName' to list all available subnets."
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "VPC CIDR to create new VPC."
  type        = string
  default     = "10.0.0.0/16"
}

## Security Groups

variable "create_cluster_security_group" {
  description = "Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default"
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "Existing security group ID to be attached to the cluster."
  type        = string
  default     = ""
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created."
  type        = string
  default     = null
}

## API Endpoint

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = false
}

#### Plugins ####
#################

## VPC CNI
variable "vpc_cni_enable_prefix_delegation" {
  description = "Increases Pod density by assigning EC2 ENIs with IP addresses prefixes instead a single IP. Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html."
  type        = bool
  default     = true
}

variable "kube_proxy" {
  description = "Kube-proxy addon configurations."
  type = object({
    mode : optional(string, "iptables"),
    resources : optional(any, {}),
    ipvs : optional(object({
      scheduler : optional(string, "rr")
    }), {})
  })
  default = {}
}

#### Fargate ####
#################

variable "fargate_profiles" {
  description = "List of fargate selectors to create. To disable fargate, set this value to `[]`."
  type        = any # list(object({namespace: string, labels: map(string)}))
  default = [
    { namespace : "kube-system", labels : { "eks.amazonaws.com/component" : "coredns" } },
    { namespace : "kube-system", labels : { "app.kubernetes.io/component" : "csi-driver" } },
    { namespace : "keda", labels : { "app.kubernetes.io/name" : "keda-operator" } },
    # Rollbacked karpenter to IRSA so it can run again on fargate
    { namespace : "karpenter", labels : { "app.kubernetes.io/name" : "karpenter" } },
    { namespace : "getup", labels : { "app" : "teleport-agent" } },
  ]
}

#### Fallback (Static) Node Group ####
######################################

variable "fallback_node_group_min_size" {
  description = "Min number of instances/nodes."
  type        = number
  default     = 0
  nullable    = false
}

variable "fallback_node_group_max_size" {
  description = "Max number of instances/nodes."
  type        = number
  default     = 1
  nullable    = false
}

variable "fallback_node_group_desired_size" {
  description = "Desired number of instances/nodes."
  type        = number
  default     = 0
  nullable    = false
}

variable "fallback_node_group_capacity_type" {
  description = " of capacity associated with the EKS Node Group. Valid values: `ON_DEMAND`, `SPOT`."
  type        = string
  default     = "ON_DEMAND"
}

variable "fallback_node_group_instance_types" {
  description = "Set of instance types associated with the EKS Node Group."
  type        = list(string)
  default     = ["c5.large", "c5.xlarge", "m5.large", "m5.xlarge", "r5.large", "r5.xlarge"]
}

variable "fallback_node_group_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values are `AL2_x86_64`, `AL2_x86_64_GPU`, `AL2_ARM_64`, `CUSTOM`, `BOTTLEROCKET_ARM_64`, `BOTTLEROCKET_x86_64`."
  type        = string
  default     = "BOTTLEROCKET_x86_64"
  validation {
    condition = contains(
      [
        "AL2_x86_64",
        "AL2_x86_64_GPU",
        "AL2_ARM_64",
        "CUSTOM",
        "BOTTLEROCKET_ARM_64",
        "BOTTLEROCKET_x86_64",
        "BOTTLEROCKET_ARM_64_NVIDIA",
        "BOTTLEROCKET_x86_64_NVIDIA",
        #"WINDOWS_CORE_2019_x86_64",
        #"WINDOWS_FULL_2019_x86_64",
        #"WINDOWS_CORE_2022_x86_64",
        #"WINDOWS_FULL_2022_x86_64",
        "AL2023_x86_64_STANDARD",
        "AL2023_ARM_64_STANDARD"
      ],
    var.fallback_node_group_ami_type)
    error_message = "Invalid value: fallback_node_group_ami_type"
  }
}

variable "fallback_node_group_platform" {
  description = "Identifies if the OS platform is `bottlerocket` or `linux` based; `windows` is not supported."
  type        = string
  default     = "bottlerocket"
}

variable "fallback_node_group_disk_size" {
  description = "Disk size in GiB for worker nodes. Defaults to 60."
  type        = number
  default     = 60
}

variable "fallback_node_group_disk_type" {
  description = "Disk type to use on the worker nodes. Defaults to gp3."
  type        = string
  default     = "gp3"
}

#### Karpenter ####
###################

variable "karpenter_enabled" {
  description = "Install Karpenter."
  type        = bool
  default     = true
}

variable "karpenter_namespace" {
  description = "Namespace where to install Karpenter."
  type        = string
  default     = "karpenter"
}

variable "karpenter_version" {
  description = "Karpenter chart version."
  type        = string
  default     = "1.5.0"
}

variable "karpenter_replicas" {
  description = "Number of pods for Karpenter controller."
  type        = number
  default     = 2
}

variable "karpenter_node_class_ami_family" {
  description = "Identifies if the OS platform is `Bottlerocket` or `AL2` based."
  type        = string
  default     = "Bottlerocket"

  validation {
    condition     = contains(["Bottlerocket", "AL2", "AL2023", "Ubuntu"], var.karpenter_node_class_ami_family)
    error_message = "Invalid value: karpenter_node_class_ami_family"
  }
}

variable "karpenter_node_pool_instance_arch" {
  description = "CPU Architecture for node pool instances. Valid values are `amd64` and `arm64`."
  type        = list(string)
  default     = ["amd64"]

  validation {
    condition     = alltrue([for arch in var.karpenter_node_pool_instance_arch : contains(["amd64", "arm64"], arch)])
    error_message = "Invalid value: karpenter_node_pool_instance_arch must be one of \"amd64\" or \"arm64\""
  }
}

variable "karpenter_node_pool_instance_category" {
  description = "EC2 Instance categories for both OnDemand and Spot Karpenter node pools."
  type        = list(string)
  default     = ["c", "m", "r"]
}

variable "karpenter_node_group_spot_ratio" {
  description = "Ratio of On-Demand/Spot nodes created managed Karpenter."
  type        = number
  default     = 0.7

  validation {
    condition     = var.karpenter_node_group_spot_ratio >= 0 && var.karpenter_node_group_spot_ratio <= 1
    error_message = "Invalid value: karpenter_node_group_spot_ratio must be in the range [0..1]."
  }
}

variable "karpenter_node_pool_instance_cpu" {
  description = "EC2 Instance vCPUs for both OnDemand and Spot Karpenter node pools."
  type        = list(string)
  default     = ["2", "4", "8"]
}

variable "karpenter_node_pool_instance_memory_gb" {
  description = "EC2 Instance memory size in GBi for both OnDemand and Spot Karpenter node pools."
  type        = list(number)
  default     = [4, 8, 16]
}

variable "karpenter_cluster_limits_memory_gb" {
  description = "Overall EC2 Instance maximum memory size in GBi for both OnDemand and Spot Karpenter node pools. This respects proportions from var.karpenter_node_group_spot_ratio."
  type        = number
  default     = 1024
}

variable "karpenter_cluster_limits_cpu" {
  description = "Overall EC2 Instance maximum vCPUs for both OnDemand and Spot Karpenter node pools. This respects proportions from var.karpenter_node_group_spot_ratio."
  type        = number
  default     = 1000
}

variable "karpenter_node_pool_taints" {
  description = "Overall EC2 Instance taints for OnDemand, Spot and Infra Karpenter node pools."
  type = object({
    infra : list(object({
      key : optional(string, "dedicated")
      value : optional(string, "infra")
      effect : optional(string, "NoSchedule")
    })),
    on-demand : list(object({
      key : optional(string, "dedicated")
      value : optional(string, "on-demand")
      effect : optional(string, "NoSchedule")
    })),
    spot : list(object({
      key : optional(string, "dedicated")
      value : optional(string, "spot")
      effect : optional(string, "NoSchedule")
    }))
  })
  default = {
    infra : [
      {
        key : "dedicated"
        value : "infra"
        effect : "NoSchedule"
      }
    ],
    on-demand : [],
    spot : []
  }
}

#### IAM ####
#############

variable "eks_iam_role_name" {
  description = "IAM role name to create for EKS."
  type        = string
  default     = ""
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster."
  type        = string
  default     = null
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(string)
  default     = []
}

## AWS Access Entries ##

variable "access_entries" {
  description = "Map of access entries to add to the cluster. See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/README.md#cluster-access-entry for details"
  type        = any
  default     = {}
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = true
}

## AWS Auth ConfigMap ##
## DEPRECATED - Use Access Entries to give permisstions for IAM principal ##
variable "create_aws_auth_configmap" {
  description = "Determines whether to create the aws-auth configmap. NOTE - this is only intended for scenarios where the configmap does not exist (i.e. - when using only self-managed node groups). Most users should use `manage_aws_auth_configmap`"
  type        = bool
  default     = false
}

variable "manage_aws_auth_configmap" {
  description = "Determines whether to manage the aws-auth configmap"
  type        = bool
  default     = false
}

variable "aws_auth_user_arns" {
  description = "List of user ARNs to add to the aws-auth configmap. K8s username will be the last component of the ARN."
  type        = list(string)
  default     = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_user_groups" {
  description = "K8s group names to assign for all ARN users to add to the aws-auth configmap"
  type        = list(string)
  default     = ["system:masters"]
}

variable "aws_auth_role_arns" {
  description = "List of roles ARNs to add to the aws-auth configmap. K8s username will be the last component of the ARN."
  type        = list(string)
  default     = []
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_role_groups" {
  description = "K8s group names to assign for all ARN users to add to the aws-auth configmap"
  type        = list(string)
  default     = ["system:masters"]
}

variable "aws_auth_accounts" {
  description = "List of account maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

#### KEDA ####
##############

variable "keda_namespace" {
  description = "Namespace where to install Keda."
  type        = string
  default     = "keda"
}

variable "keda_version" {
  description = "Keda chart version."
  type        = string
  default     = "2.12.1"
}

variable "keda_replicas" {
  description = "Number of pods for Keda workloads."
  type        = number
  default     = 2
}

variable "keda_cron_schedule" {
  description = "Timebased autoscale configurations."
  type = list(object({
    apiVersion      = string
    kind            = string
    name            = string
    namespace       = string
    minReplicaCount = number
    maxReplicaCount = number
    schedules = list(object({
      timezone        = string
      start           = string
      end             = string
      desiredReplicas = string
    }))
  }))
  default = []
}

#### Baloon Deploy #####
########################

variable "baloon_chart_version" {
  description = "Baloon chart version."
  type        = string
  default     = "0.2.0"
}

variable "baloon_namespace" {
  description = "Namespace to install baloon chart."
  type        = string
  default     = "default"
}

variable "baloon_replicas" {
  description = "Number of pods for Baloon deployment (i.e. zero-resources usage pods). See https://wdenniss.com/gke-autopilot-spare-capacity for details."
  type        = number
  default     = 0
}

variable "baloon_cpu" {
  description = "Request and limit CPU size for each baloon pod."
  type        = number
  default     = 1
}

variable "baloon_memory" {
  description = "Request and limit memory size for each baloon pod."
  type        = string
  default     = "8Mi"
}
