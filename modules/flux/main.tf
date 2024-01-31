data "aws_caller_identity" "current" {}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "flux" {
  title      = "EKS Flux - ${var.cluster_name} (Account ID: ${data.aws_caller_identity.current.account_id}, Region: ${var.aws_region})"
  repository = var.flux_github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = false
}

resource "flux_bootstrap_git" "flux" {
  interval       = "5m"
  path           = var.flux_path
  namespace      = "flux-system"
  network_policy = true
  #kustomization_override = "" ## see https://registry.terraform.io/providers/fluxcd/flux/latest/docs/resources/bootstrap_git#kustomization_override
  recurse_submodules = true
  toleration_keys    = ["NoSchedule"]

  components       = ["source-controller", "kustomize-controller", "helm-controller", "notification-controller"]
  components_extra = ["image-reflector-controller", "image-automation-controller"]

  depends_on = [
    github_repository_deploy_key.flux
  ]
}

