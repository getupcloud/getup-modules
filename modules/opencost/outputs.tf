output "opencost_iam_role_arn" {
  description = "OpenCost role ARN."
  value       = module.opencost_irsa.iam_role_arn
}

output "opencost_spot_datafeed_bucket_name" {
  description = "Bucket name for Spot Instance Data Feed. Must there be only one bucket configured to receive spot usage data."
  value       = var.opencost_spot_datafeed_bucket_name
}

output "opencost_spot_datafeed_bucket_prefix" {
  description = "Prefix to retain Spot Instance Data Feed files in S3."
  value       = var.opencost_spot_datafeed_bucket_prefix
}
