#### Cluster ####
#################

variable "cluster_name" {
  description = "DOKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes controlplane version. Use 'doctl kubernetes options versions' to list available versions."
  type        = string
  default     = "1.32.2-do.0"
}

variable "region" {
  description = "DigitalOcean Region slug. Use 'doctl compute region list -o json | jq '.[]|\"\\(.slug): \\(.name)\"' -r | sort' to list all available  regions."
  type        = string
}

variable "control_plane_ha" {
  description = "Enable/disable the high availability control plane for a cluster. Once enabled for a cluster, high availability cannot be disabled."
  type        = bool
  default     = false
}

variable "auto_upgrade" {
  description = "Should the cluster will be automatically upgraded to new patch releases during its maintenance window"
  type        = bool
  default     = false
}

variable "maintenance_policy" {
  description = "(Optional) A block representing the cluster's maintenance window. Variable 'auto_upgrade' must be set to true for this to have an effect"
  type        = object({ day : string, start_time : string })
  default = {
    day        = "sunday"
    start_time = "03:00"
  }
}

variable "surge_upgrade" {
  description = "Should upgrades bringing up new nodes before destroying the outdated nodes"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = any
  default = {
    "managed-by" : "terraform"
  }
}

variable "registry_integration" {
  description = "optional) Enables or disables the DigitalOcean container registry integration for the cluster."
  type        = bool
  default     = true
}

#### Network ####
#################

## Use an existing VPC

variable "vpc_uuid" {
  description = "(optional) VPC UUID of an existing VPC. Set a value to disable VPC creation."
  type        = string
  default     = ""
}

## Create a new VPC

variable "vpc_name" {
  description = "(optional) VPC name to create a new VPC. Defaults to cluster name."
  type        = string
  default     = ""
}

variable "vpc_ip_range" {
  description = "(optional) IP range in CIDR notation for a new VPC."
  type        = string
  default     = null
}

variable "vpc_description" {
  description = "(optional) Description for new VPC"
  type        = string
  default     = "VPC for Kubernetes cluster."
}

#### Node Pools ####
####################

variable "default_node_pool" {
  description = "Default node pool config"
  type        = any
  default = {
    name       = "default"
    size       = "s-4vcpu-8gb"
    node_count = 2
    auto_scale = false
    min_nodes  = 2
    max_nodes  = 2
    tags       = []

    labels = {
      "role-role.getup.io/infra" : ""
    }

    ## Format is list(taint): [{key:XXX, value: XXX, effect:XXX},...]
    taints = [{
      key    = "dedicated"
      value  = "infra"
      effect = "NoSchedule"
    }]
  }
}

variable "node_pools" {
  description = "List of extra node pools"
  type        = list(any)
  default = [
    {
      name       = "app"
      size       = "s-4vcpu-8gb"
      node_count = 2
      auto_scale = true
      min_nodes  = 2
      max_nodes  = 4
      tags       = []

      labels = {
        "role-role.kubernetes.io/app" : ""
      }

      ## Format is list(taint): [{key:XXX, value: XXX, effect:XXX},...]
      taints = []
    }
  ]
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
