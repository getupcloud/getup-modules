terraform {
  required_version = "~> 1.7.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.2"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.18"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}
