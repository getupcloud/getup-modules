provider "flux" {
  kubernetes = {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "awslocal"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
    }
  }

  git = {
    url = "ssh://git@localhost/fake/fake.git"
    ssh = {
      username    = "git"
      private_key = module.flux.private_key_pem
    }
  }
}

