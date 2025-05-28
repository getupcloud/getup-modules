terraform {
  required_version = "~> 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.2"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.18"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }

  }
}
