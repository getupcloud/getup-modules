terraform {
  required_version = "~> 1.12"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.2"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.6"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}
