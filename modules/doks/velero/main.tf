resource "digitalocean_spaces_bucket" "velero" {
  name   = "velero-${var.velero_bucket_name}"
  region = var.velero_bucket_region

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    prefix  = var.velero_prefix_path

    expiration {
      days                         = "60"
      expired_object_delete_marker = true
    }
  }
}

resource "digitalocean_spaces_key" "velero" {
  name = "velero-${var.velero_bucket_name}"

  grant {
    bucket     = var.velero_bucket_name
    permission = "readwrite"
  }
}
