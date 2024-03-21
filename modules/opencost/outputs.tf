output "opencost_iam_role_arn" {
  description = "OpenCost role ARN."
  value       = module.opencost_irsa.iam_role_arn
}
