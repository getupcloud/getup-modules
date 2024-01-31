#locals {
#  istio_base_values = (var.istio_base_values[0] == '/' || var.istio_base_values[0] '.') ? var.istio_base_values : "${}"
#}

resource "helm_release" "istio-base" {
  namespace        = var.istio_namespace
  create_namespace = true

  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = var.istio_version

  values = [file(var.istio_base_values)]

  dynamic "set" {
    for_each = var.istio_base_set

    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = try(set.value["type"], "any")
    }
  }

  dynamic "set_list" {
    for_each = var.istio_base_set_list

    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }
}
