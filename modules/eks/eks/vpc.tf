data "aws_vpc" "eks" {
  id = local.vpc_id
}

module "vpc" {
  count   = var.vpc_id == "" ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name != "" ? var.vpc_name : local.cluster_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.cluster_name
  }

  tags = local.tags
}

resource "aws_ec2_tag" "public_subnets_elb" {
  for_each    = toset(var.public_subnet_ids)
  resource_id = each.key
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnets_elb" {
  for_each    = toset(var.private_subnet_ids)
  resource_id = each.key
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnets_karpenter" {
  for_each    = toset(var.private_subnet_ids)
  resource_id = each.key
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}
