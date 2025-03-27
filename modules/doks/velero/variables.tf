variable "velero_prefix_path" {
  description = "Bucket prefix to create objets."
  type        = string
  default     = "velero/"
}

variable "velero_bucket_name" {
  description = "Bucket Name."
  type        = string
}

variable "velero_bucket_region" {
  description = "Bucket Region."
  type        = string
}
