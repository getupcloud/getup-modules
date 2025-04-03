locals {
  bucket_name = (var.velero_bucket_name != "") ? var.velero_bucket_name : "${var.velero_bucket_name_prefix}${random_uuid.bucket_name_suffix.result}"
}

resource "random_uuid" "bucket_name_suffix" {}

resource "digitalocean_spaces_bucket" "velero" {
  name   = local.bucket_name
  region = var.velero_bucket_region
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    prefix  = var.velero_prefix_path

    expiration {
      days = 60
      #expired_object_delete_marker = true
    }
  }
}

resource "digitalocean_spaces_key" "velero" {
  name = digitalocean_spaces_bucket.velero.name

  grant {
    bucket     = digitalocean_spaces_bucket.velero.name
    permission = "readwrite"
  }
}
