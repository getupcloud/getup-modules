# File auto-generated by ./bin/make-example-main for $doks cluster

module "loki" {
  source = "git@github.com:getupcloud/getup-modules//modules/doks/loki?ref=v1.2.7"

  loki_prefix_path        = var.loki_prefix_path
  loki_bucket_name        = var.loki_bucket_name
  loki_bucket_name_prefix = var.loki_bucket_name_prefix
  loki_bucket_region      = var.region
}
