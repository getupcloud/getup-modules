# File auto-generated from ./bin/module2example

module "istio" {
  source = "github.com/getupcloud/terraform-modules//modules/istio?ref=v0.0.11"

  istio_version       = var.istio_version
  istio_namespace     = var.istio_namespace
  istio_base_values   = var.istio_base_values
  istio_base_set      = var.istio_base_set
  istio_base_set_list = var.istio_base_set_list
}
