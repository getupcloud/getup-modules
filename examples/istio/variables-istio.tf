# File auto-generated from ./bin/filter-vars

#### Istio #####
################

variable "istio_version" {
  description = "Istio version."
  type        = string
  default     = "1.20.2"
}

variable "istio_namespace" {
  description = "Istio namespace."
  type        = string
  default     = "istio-system"
}

## Istio Base
#############

variable "istio_base_values" {
  description = "Path to istio-base values file. Start it with / for absolute path or ./ to relative to root module. Set it to empty string to ignore."
  type        = string
  default     = ""
}

variable "istio_base_set" {
  description = "Value block with custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = any }))
  default     = [{ "name" : "base.enableCRDTemplates", "value" : false }]
}

variable "istio_base_set_list" {
  description = "Value block with list of custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = list(any) }))
  default     = []
}

## Istiod
#########

variable "istiod_values" {
  description = "Path to istiod values file. Start with / for absolute path or ./ to relative to root module. Set it to empty string to ignore."
  type        = string
  default     = ""
}

variable "istiod_set" {
  description = "Value block with custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = any }))
  default     = []
}

variable "istiod_set_list" {
  description = "Value block with list of custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = list(string) }))
  default     = []
}

## Ingress Gateway
##################

variable "ingress_gateway_values" {
  description = "Path to istio ingress-gateway values file. Start with / for absolute path or ./ to relative to root module. Set it to empty string to ignore."
  type        = string
  default     = ""
}

variable "ingress_gateway_set" {
  description = "Value block with custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = string }))
  default = [{
    "name" : "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type",
    "value" : "nlb",
  }]
}

variable "ingress_gateway_set_list" {
  description = "Value block with list of custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = list(string) }))
  default     = []
}

## Egress Gateway
#################

variable "egress_gateway_values" {
  description = "Path to istio egress-gateway values file. Start with / for absolute path or ./ to relative to root module. Set it to empty string to ignore."
  type        = string
  default     = ""
}

# Egress is just a plain gateway without a load balancer.
variable "egress_gateway_set" {
  description = "Value block with custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = string }))
  default     = [{ "name" : "service.type", "value" : "ClusterIP" }]
}

variable "egress_gateway_set_list" {
  description = "Value block with list of custom values to be merged with the values yaml."
  type        = list(object({ name = string, value = list(string) }))
  default     = []
}
