resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "flux" {
  title      = "DOKS Flux - ${var.flux_cluster_name} (Region: ${var.flux_region})"
  repository = var.flux_github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = false
}

resource "flux_bootstrap_git" "flux" {
  interval       = "10m"
  path           = var.flux_path
  namespace      = "flux-system"
  network_policy = true
  #kustomization_override = "" ## see https://registry.terraform.io/providers/fluxcd/flux/latest/docs/resources/bootstrap_git#kustomization_override
  recurse_submodules = true
  toleration_keys    = ["NoSchedule"]
  version            = var.flux_version

  components       = ["source-controller", "kustomize-controller", "helm-controller", "notification-controller"]
  components_extra = ["image-reflector-controller", "image-automation-controller"]

  depends_on = [
    github_repository_deploy_key.flux
  ]
}

#resource "kubectl_manifest" "flux-apps" {
#  yaml_body = <<-EOF
#    apiVersion: kustomize.toolkit.fluxcd.io/v1
#    kind: Kustomization
#    metadata:
#      name: apps
#      namespace: flux-system
#    spec:
#      interval: 10m
#      path: ./apps
#      prune: true
#      sourceRef:
#        kind: GitRepository
#        name: flux-system
#      decryption:
#        provider: sops
#  EOF
#
#  depends_on = [
#    flux_bootstrap_git.flux
#  ]
#}
