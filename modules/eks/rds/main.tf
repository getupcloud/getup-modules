locals {
  rds_engine_ingress = {
    postgres : {
      name : "PostgreSQL"
      port : 5432
    }
  }

  db_name  = coalesce(var.rds_db_name, var.rds_name)
  username = coalesce(var.rds_username, var.rds_db_name, var.rds_name)
  password = var.rds_password

  tags = merge(var.rds_tags, {
    "managed-by" : "terraform"
  })
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name       = coalesce(var.rds_vpc_name, "rds-${var.rds_name}")
  cidr       = var.rds_vpc_cidr
  create_vpc = true

  azs                                    = var.rds_vpc_zones # better if matches eks azs
  database_subnets                       = [for k, v in var.rds_vpc_zones : cidrsubnet(var.rds_vpc_cidr, 4, k)]
  create_database_subnet_route_table     = true
  database_subnet_names                  = [for k, v in var.rds_vpc_zones : "rds-subnet-${k}"]
  create_database_subnet_group           = true
  create_database_internet_gateway_route = var.rds_public

  enable_dns_hostnames = true
  enable_dns_support   = var.rds_public
  create_igw           = var.rds_public

  default_security_group_ingress = [for cidr in distinct(compact(concat([var.rds_eks_vpc_cidr], var.rds_ingress_vpc_cidrs))) : {
    from_port   = local.rds_engine_ingress[var.rds_engine].port
    to_port     = local.rds_engine_ingress[var.rds_engine].port
    protocol    = "tcp"
    description = "${local.rds_engine_ingress[var.rds_engine].name} access from ${cidr}"
    cidr_blocks = cidr
  }]

  tags = local.tags
}

module "database" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.6.0"

  identifier = var.rds_name

  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  family               = var.rds_family
  major_engine_version = var.rds_major_engine_version
  instance_class       = var.rds_instance_class

  allocated_storage     = var.rds_storage_size
  max_allocated_storage = var.rds_storage_size * 5

  db_name  = local.db_name
  username = local.username
  password = local.password
  port     = local.rds_engine_ingress[var.rds_engine].port

  manage_master_user_password                       = local.password == null
  manage_master_user_password_rotation              = false
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "rate(15 days)"

  multi_az               = length(var.rds_vpc_zones) > 1
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.vpc.default_security_group_id]

  maintenance_window                    = "Mon:00:00-Mon:03:00"
  backup_window                         = "03:00-06:00"
  backup_retention_period               = 1
  skip_final_snapshot                   = true
  deletion_protection                   = var.rds_deletion_protection
  performance_insights_enabled          = var.performance_insights_retention_period == 0 ? false : var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
}

module "vpc_peering" {
  #source = "git@github.com:getupcloud/terraform-modules//modules/eks/vpc_peering?ref=v1.2.7"
  source = "../vpc_peering"
  count  = var.rds_vpc_peering_peer_vpc_id != null ? 1 : 0

  vpc_peering_owner_vpc_id          = module.vpc.vpc_id
  vpc_peering_owner_route_table_ids = module.vpc.database_route_table_ids
  vpc_peering_peer_vpc_id           = var.rds_vpc_peering_peer_vpc_id
  vpc_peering_peer_route_table_ids  = var.rds_vpc_peering_peer_route_table_ids
}
