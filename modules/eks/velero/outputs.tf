output "velero_iam_role_arn" {
  description = "Velero Role ARN."
  value       = module.velero_s3_irsa.iam_role_arn
}

output "velero_s3_bucket_name" {
  description = "Velero S3 Bucket name."
  value       = module.velero_s3_bucket.s3_bucket_id
}
