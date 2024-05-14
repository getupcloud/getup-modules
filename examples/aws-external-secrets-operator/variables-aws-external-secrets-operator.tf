# File auto-generated from ./bin/filter-vars

#variable "aws_eso_cluster_oidc_issuer_url" {
#  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
#  type        = string
#}

variable "aws_eso_namespace" {
  description = "Namespace for Service Account"
  type        = string
  default     = "external-secrets"
}

variable "aws_eso_service_account" {
  description = "Service Account name"
  type        = string
  default     = "external-secrets"
}

#variable "aws_eso_aws_region" {
#  description = "(Optional) AWS Region where is located AWS Secret Manager"
#  type        = string
#  default     = ""
#}

variable "aws_eso_aws_account_id" {
  description = "(Optional) AWS Account ID where is located AWS Secret Manager"
  type        = string
  default     = ""
}

variable "aws_eso_create_secrets" {
  description = "(Optional) List of secret names to create."
  type        = list(string)
  default     = []
}

variable "aws_eso_secrets" {
  description = "(Optional) List of existing secrets. Can be either a arn or a secret name."
  type        = list(string)
  default     = []
}

variable "aws_eso_tags" {
  description = "(Optional) Tags to apply to all created resources."
  type        = any
  default     = {}
}
