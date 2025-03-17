output "tempo_iam_role_arn" {
  description = "Tempo Role ARN."
  value       = module.tempo_s3_irsa.iam_role_arn
}

output "tempo_s3_bucket_name" {
  description = "Tempo S3 Bucket name."
  value       = module.tempo_s3_bucket.s3_bucket_id
}
