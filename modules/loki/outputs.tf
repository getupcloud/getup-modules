output "loki_iam_role_arn" {
  description = "Loki Role ARN."
  value       = module.loki_irsa.iam_role_arn
}

output "loki_s3_bucket_name" {
  description = "Loki S3 Bucket name."
  value       = aws_s3_bucket.s3_loki.id
}
