### Flux ###
############

output "private_key_pem" {
  description = "TLS Private keys for flux git repository."
  value       = tls_private_key.flux.private_key_pem
  sensitive   = true
}
