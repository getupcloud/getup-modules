variable "${name_}_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
}

variable "${name_}_namespace" {
  description = "Namespace for Service Account"
  type        = string
}

variable "${name_}_service_account" {
  description = "Service Account name"
  type        = string
}

variable "${name_}_aws_region" {
  description = "(Optional) AWS Region where is located ${DISPLAY_NAME}"
  type        = string
  default     = ""
}

variable "${name_}_aws_account_id" {
  description = "(Optional) AWS Account ID where is located ${DISPLAY_NAME}"
  type        = string
  default     = ""
}

variable "${name_}_tags" {
  description = "(Optional) Tags to apply to all resources."
  type        = any
  default     = {}
}
