#### ArgoCD #####
#################

variable "argocd_repository" {
  description = "Argo CD chart repository."
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argocd_version" {
  description = "Argo CD version."
  type        = string
  default     = "5.54.0"
}

variable "argocd_namespace" {
  description = "Argo CD namespace."
  type        = string
  default     = "argocd"
}

variable "argocd_values" {
  description = "Path to argocd values file. The file is relative to root module path. Set it to empty string to ignore."
  type        = string
  default     = ""
}

variable "argocd_set" {
  description = "Value block with custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = string }))
  default = [
    { "name" : "redis-ha.enabled", "value" : "false" },
    { "name" : "controller.replicas", "value" : "1" },
    { "name" : "server.autoscaling.enabled", "value" : "true" },
    { "name" : "server.autoscaling.minReplicas", "value" : "1" },
    { "name" : "repoServer.autoscaling.enabled", "value" : "true" },
    { "name" : "repoServer.autoscaling.minReplicas", "value" : "1" },
    { "name" : "applicationSet.replicas", "value" : "1" },
  ]
}

variable "argocd_set_list" {
  description = "Value block with list of custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = list(string) }))
  default     = []
}
