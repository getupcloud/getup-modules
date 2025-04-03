output "tempo_bucket_name" {
  description = "Tempo Bucket name."
  value       = local.bucket_name
}

output "tempo_access_key" {
  description = "Tempo Access Key ID."
  value       = digitalocean_spaces_key.tempo.access_key
}

output "tempo_secret_key" {
  description = "Tempo Secret Key."
  value       = digitalocean_spaces_key.tempo.secret_key
  sensitive   = true
}
