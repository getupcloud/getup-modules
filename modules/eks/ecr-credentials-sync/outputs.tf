output "ecr_credentials_sync_iam_role_arn" {
  description = "ECR Credentials Sync Role ARN."
  value       = module.ecr_credentials_sync.iam_role_arn
}
