locals {
  istio_base_values_default = !(startswith("/", var.istio_base_values) || startswith("./", var.istio_base_values))
  istio_base_values = (var.istio_base_values == "") ? [] : [
    local.istio_base_values_default ? "${path.module}/${var.istio_base_values}" : var.istio_base_values
  ]

  istiod_values_default = !(startswith("/", var.istiod_values) || startswith("./", var.istiod_values))
  istiod_values = (var.istiod_values == "") ? [] : [
    local.istiod_values_default ? "${path.module}/${var.istiod_values}" : var.istiod_values
  ]

  ingress_gateway_values_default = !(startswith("/", var.ingress_gateway_values) || startswith("./", var.ingress_gateway_values))
  ingress_gateway_values = (var.ingress_gateway_values == "") ? [] : [
    local.ingress_gateway_values_default ? "${path.module}/${var.ingress_gateway_values}" : var.ingress_gateway_values
  ]

  egress_gateway_values_default = !(startswith("/", var.egress_gateway_values) || startswith("./", var.egress_gateway_values))
  egress_gateway_values = (var.egress_gateway_values == "") ? [] : [
    local.egress_gateway_values_default ? "${path.module}/${var.egress_gateway_values}" : var.egress_gateway_values
  ]
}

resource "helm_release" "istio-base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = var.istio_version
  namespace        = var.istio_namespace
  create_namespace = true

  values = [for f in local.istio_base_values : file(f)]

  dynamic "set" {
    for_each = var.istio_base_set

    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = try(set.value["type"], "auto")
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

resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  version          = var.istio_version
  namespace        = var.istio_namespace
  create_namespace = true

  values = [for f in local.istiod_values : file(f)]

  dynamic "set" {
    for_each = var.istiod_set

    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = try(set.value["type"], "auto")
    }
  }

  dynamic "set_list" {
    for_each = var.istiod_set_list

    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }

  depends_on = [
    helm_release.istio-base
  ]
}
resource "helm_release" "ingress-gateway" {
  name             = "istio-ingressgateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  version          = var.istio_version
  namespace        = var.istio_namespace
  create_namespace = true

  values = [for f in local.ingress_gateway_values : file(f)]

  dynamic "set" {
    for_each = var.ingress_gateway_set

    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = try(set.value["type"], "auto")
    }
  }

  dynamic "set_list" {
    for_each = var.ingress_gateway_set_list

    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }

  depends_on = [
    helm_release.istio-base
  ]
}
resource "helm_release" "egress-gateway" {
  name             = "istio-egressgateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  version          = var.istio_version
  namespace        = var.istio_namespace
  create_namespace = true

  values = [for f in local.egress_gateway_values : file(f)]

  dynamic "set" {
    for_each = var.egress_gateway_set

    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = try(set.value["type"], "auto")
    }
  }

  dynamic "set_list" {
    for_each = var.egress_gateway_set_list

    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }

  depends_on = [
    helm_release.istio-base
  ]
}
