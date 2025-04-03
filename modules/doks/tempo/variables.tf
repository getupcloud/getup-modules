variable "tempo_prefix_path" {
  description = "Bucket prefix to create objets."
  type        = string
  default     = "tempo/"
}

variable "tempo_bucket_name" {
  description = "Bucket Name. Use as-is if provided, otherwise uses tempo_bucket_name_prefix to create a random name."
  type        = string
  default     = ""
}

variable "tempo_bucket_name_prefix" {
  description = "(Optional) Auto-generated bucket name prefix. Ignored if tempo_bucket_name is provided."
  type        = string
  default     = "tempo-"
}

variable "tempo_bucket_region" {
  description = "Bucket Region."
  type        = string
}
