output "cert_manager_iam_role_arn" {
  description = "Cert-Manager Role ARN."
  value       = module.cert_manager_irsa.iam_role_arn
}

