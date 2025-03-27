output "velero_bucket_name" {
  description = "Velero Bucket name."
  value       = digitalocean_spaces_bucket.velero.name
}

output "velero_access_key" {
  description = "Velero Access Key ID."
  value       = digitalocean_spaces_key.velero.access_key
}

output "velero_secret_key" {
  description = "Velero Secret Key."
  value       = digitalocean_spaces_key.velero.secret_key
  sensitive   = true
}
