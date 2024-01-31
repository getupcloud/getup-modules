#### Istio #####
################

variable "istio_version" {
  description = "Istio version."
  type        = string
  default     = "1.18.2"
}

variable "istio_namespace" {
  description = "Istio namespace."
  type        = string
  default     = "istio-system"
}

variable "istio_base_values" {
  description = "Path to istio-base values file. Start it with / for absolute path or ./ to relative to root module."
  type        = string
  default     = "base-values.yaml"
}

variable "istio_base_set" {
  description = "Value block with custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "istio_base_set_list" {
  description = "Value block with list of custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = list(any) }))
  default     = []
}
