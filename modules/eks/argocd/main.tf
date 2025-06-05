locals {
  argocd_values_default = !(startswith("/", var.argocd_values) || startswith("./", var.argocd_values))
  argocd_values = (var.argocd_values == "") ? [] : [
    local.argocd_values_default ? "${path.root}/${var.argocd_values}" : var.argocd_values
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = var.argocd_repository
  chart            = "argo-cd"
  version          = var.argocd_version
  namespace        = var.argocd_namespace
  create_namespace = true
  timeout          = 60 * 20

  values = [for f in local.argocd_values : file(f)]

  dynamic "set" {
    for_each = var.argocd_set

    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = try(set.value["type"], "auto")
    }
  }

  dynamic "set_list" {
    for_each = var.argocd_set_list

    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }
}
