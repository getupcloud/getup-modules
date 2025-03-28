locals {
  bucket_name = (var.loki_bucket_name != "") ? var.loki_bucket_name : "${var.loki_bucket_name_prefix}${random_uuid.bucket_name_suffix.result}"
}

resource "random_uuid" "bucket_name_suffix" {}

resource "digitalocean_spaces_bucket" "loki" {
  name   = local.bucket_name
  region = var.loki_bucket_region
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    prefix  = var.loki_prefix_path

    expiration {
      days = 60
      #expired_object_delete_marker = true
    }
  }
}

resource "digitalocean_spaces_key" "loki" {
  name = local.bucket_name

  grant {
    bucket     = local.bucket_name
    permission = "readwrite"
  }
}
