output "external_dns_iam_role_arn" {
  description = "External DNS role ARN."
  value       = module.external_dns_irsa.iam_role_arn
}
