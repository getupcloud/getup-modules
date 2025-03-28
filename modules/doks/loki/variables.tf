variable "loki_prefix_path" {
  description = "Bucket prefix to create objets."
  type        = string
  default     = "loki/"
}

variable "loki_bucket_name" {
  description = "Bucket Name. Use as-is if provided, otherwise uses loki_bucket_name_prefix to create a random name."
  type        = string
  default     = ""
}

variable "loki_bucket_name_prefix" {
  description = "(Optional) Auto-generated bucket name prefix. Ignored if loki_bucket_name is provided."
  type        = string
  default     = "loki-"
}

variable "loki_bucket_region" {
  description = "Bucket Region."
  type        = string
}
