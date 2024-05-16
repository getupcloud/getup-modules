### Flux ###
############

output "private_key_pem" {
  description = "TLS Private keys for flux git repository."
  value       = tls_private_key.flux.private_key_pem
  sensitive   = true
}

output "flux_overlay" {
  description = "Map of variables to inject into overlay files."
  value       = var.flux_overlay
}
