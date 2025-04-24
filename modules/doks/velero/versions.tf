terraform {
  required_version = "1.11.x"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.11"
    }
  }
}
