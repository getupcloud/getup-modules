variable "velero_do_token" {
  description = "DigitalOcean API Token"
  type        = string
  default     = ""
}

variable "velero_tags" {
  description = "Tags to apply to all resources."
  type        = any
  default     = {}
}

variable "velero_retention_days" {
  description = "Days to retain files in S3."
  type        = number
  default     = 15
}

variable "velero_retention_prefixes" {
  description = "Prefixes to retain files in S3."
  type        = list(string)
  default     = ["/"]
}
