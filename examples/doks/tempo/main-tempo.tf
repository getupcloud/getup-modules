# File auto-generated by ./bin/make-example-main for $doks cluster

module "tempo" {
  source = "git@github.com:getupcloud/getup-modules//modules/doks/tempo?ref=v1.2.9"

  tempo_prefix_path        = var.tempo_prefix_path
  tempo_bucket_name        = var.tempo_bucket_name
  tempo_bucket_name_prefix = var.tempo_bucket_name_prefix
  tempo_bucket_region      = var.tempo_bucket_region
}
