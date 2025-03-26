output "velero_s3_bucket_name" {
  description = "Velero S3 Bucket name."
  value       = module.velero_s3_bucket.s3_bucket_id
}
