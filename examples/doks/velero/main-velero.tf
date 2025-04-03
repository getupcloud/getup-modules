# File auto-generated by ./bin/make-example-main for $doks cluster

module "velero" {
  source = "git@github.com:getupcloud/getup-modules//modules/doks/velero?ref=v1.2.8"

  velero_prefix_path        = var.velero_prefix_path
  velero_bucket_name        = var.velero_bucket_name
  velero_bucket_name_prefix = var.velero_bucket_name_prefix
  velero_bucket_region      = var.region
}
