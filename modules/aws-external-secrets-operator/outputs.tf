output "aws_eso_iam_role_arn" {
  description = "AWS External Secrets Operator role ARN."
  value       = module.aws_eso_irsa.iam_role_arn
}
