output "loki_bucket_name" {
  description = "Loki Bucket name."
  value       = local.bucket_name
}

output "loki_access_key" {
  description = "Loki Access Key ID."
  value       = digitalocean_spaces_key.loki.access_key
}

output "loki_secret_key" {
  description = "Loki Secret Key."
  value       = digitalocean_spaces_key.loki.secret_key
  sensitive   = true
}
