terraform {
  required_version = "~> 1.12"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.11"
    }
  }
}
